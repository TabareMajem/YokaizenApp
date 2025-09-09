package com.qcwireless.sdksample

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.hjq.permissions.OnPermissionCallback
import com.hjq.permissions.Permission.BLUETOOTH_CONNECT
import com.hjq.permissions.XXPermissions
import com.oudmon.ble.base.bluetooth.BleOperateManager
import com.oudmon.ble.base.bluetooth.DeviceManager
import com.oudmon.ble.base.bluetooth.ListenerKey
import com.oudmon.ble.base.communication.CommandHandle
import com.oudmon.ble.base.communication.LargeDataHandler
import com.oudmon.ble.base.communication.bigData.AlarmNewEntity
import com.oudmon.ble.base.communication.entity.AlarmEntity
import com.oudmon.ble.base.communication.req.SetDrinkAlarmReq
import com.oudmon.ble.base.communication.responseImpl.DeviceNotifyListener
import com.oudmon.ble.base.communication.rsp.BaseRspCmd
import com.oudmon.ble.base.communication.rsp.DeviceNotifyRsp
import com.oudmon.ble.base.util.DateUtil
import com.qcwireless.sdksample.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private val test = Test()
    private lateinit var myDeviceNotifyListener:MyDeviceNotifyListener

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initView()
    }

    private fun initView() {
        setOnClickListener(binding.tvScan) {
            requestLocationPermission(this@MainActivity, PermissionCallback())
        }

        myDeviceNotifyListener=MyDeviceNotifyListener()

        binding.run {
            tvName.text = DeviceManager.getInstance().deviceName
            val connect = BleOperateManager.getInstance().isConnected
            tvConnect.text = connect.toString()

            setOnClickListener(
                btnSetTime,
                btnFindWatch,
                btnBattery,
                btnTimeUnit,
                btnMsgTest,
                btnAlarmRead,
                btnAlarmWrite,
                btnSyncBloodoxygen,
                btnTakePicture,
                btnMusic,
                btnCall,
                btnTarget,
                tvReconnect,
                tvDisconnect,
                btnWatchFace,
                btnSleep,
                btnSleepCalc,
                heart1,
                heart2,
                heart3,
                push1,
                push2,
                temperature1,
                temperature2,
                userprofile1,
                userprofile2,
                addListener1,
                addListener2,
                addListener3,
                ota,
                bt,
                btnDrink,
                btnSport,
                pressure1
            ) {
                when (this) {
                    tvReconnect->{
                        BleOperateManager.getInstance().connectDirectly(DeviceManager.getInstance().deviceAddress)
                    }
                    tvDisconnect->{
                        BleOperateManager.getInstance().unBindDevice()
                    }
                    btnSetTime -> {
                        test.setTime()
                    }
                    btnFindWatch -> {
                        test.findPhone()
                    }
                    btnBattery -> {
                        test.battery
                    }
                    btnTimeUnit -> {
                        test.readMetricAndTimeFormat()
                    }
                    btnMsgTest->{
                        test.pushMsg()
                    }
                    btnAlarmRead->{
                        test.readAlarm()
                    }
                    btnAlarmWrite->{
                        val list= mutableListOf<AlarmNewEntity.AlarmBean>()
                        val bean=AlarmNewEntity.AlarmBean()
                        bean.content="1234"
                        bean.min=DateUtil().todayMin+1
                        bean.repeatAndEnable=0xff
                        bean.alarmLength=4+ bean.content.encodeToByteArray().size
                        list.add(bean)
                        val entity=AlarmNewEntity()
                        entity.total=1
                        entity.data=list
                        test.writeAlar(entity)
                    }
                    btnSyncBloodoxygen->{
                        test.bloodOxygen()
                    }
                    btnTakePicture->{
                        test.takePicture()
                    }
                    btnMusic->{
                        test.music()
                    }
                    btnCall->{
                        test.call()
                    }
                    btnTarget->{
                        test.setTarget()
                    }
                    btnWatchFace->{
                        test.watchFace()
                    }
                    btnSleep->{
                        test.sleep()
                    }
                    btnSleepCalc->{
//                        test.calc()
//                        test.newSleep()
                        test.contactList()
                    }
                    heart1->{
//                        test.heart()
                        test.heartSync()
//                        LargeDataHandler.getInstance().syncManualHeartRateList(
//                            0
//                        ) {
//                            Log.i("",it.index.toString())
//                            Log.i("",it.data.size.toString())
//                        }

                    }
                    heart2->{
                        test.bp()
                    }
                    heart3->{
                        test.spo2()
                    }
                    pressure1->{
                        test.pressure()
                    }
                    push1 ->{
                        test.push1()
                    }
                    push2->{
                        test.push2()
                    }
                    temperature1->{
                        test.registerTempCallback()
                        test.syncAutoTemperature()
                    }
                    temperature2->{
                        test.syncManual()
                    }
                    userprofile1->{
                        test.setUserProfile()
                    }
                    userprofile2->{
                        test.getUserProfile()
                    }
                    addListener1->{
                        BleOperateManager.getInstance().addOutDeviceListener(ListenerKey.Heart,myDeviceNotifyListener)
                    }
                    addListener2->{
                        BleOperateManager.getInstance().removeNotifyListener(ListenerKey.Heart)
                    }
                    addListener3->{
                        BleOperateManager.getInstance().removeNotifyListener(ListenerKey.All)
                    }
                    ota->{
                        startKtxActivity<OtaActivity>()
                    }
                    bt->{
//                        //获取BT的地址和名称
//                        LargeDataHandler.getInstance().syncClassicBluetooth {
//                            //返回BT的地址和名称
//                        }
//                        //查询系统蓝牙是否已经绑定这个地址
//                        val device = BleOperateManager.getInstance()
//                            .getMacSystemBond(String mac)
//                        //如果device ！=null代表已经绑定，调用连接
//                        //rtk
//                        BleOperateManager.getInstance().connectRtkSPP(device)
//                        //bk
//                        BleOperateManager.getInstance().createBondBlueTooth(device)
//                        //如果没有绑定，device==null,启动经典蓝牙扫描，可自己实现
//                        BleOperateManager.getInstance().classicBluetoothStartScan()
//                        //监听系统经典蓝牙扫描广播监听，  BluetoothDevice.ACTION_FOUND
//                        //通过返回的设备mac和手表给的匹配，
//                        BleOperateManager.getInstance().connectRtkSPP(device)
                    }
                    btnDrink->{
                        for(index in 0..6){
                            val entity = AlarmEntity(index, 1, index+5, index*5, 0x80.toByte())
                            CommandHandle.getInstance().executeReqCmdNoCallback(
                                SetDrinkAlarmReq(entity)
                            )
                        }
                    }
                    btnSport->{
//                        test.syncSport()
//                        test.heartEnable()
                        binding.tvHard.text=MyApplication.getInstance.hardwareVersion
                        binding.tvFir.text=MyApplication.getInstance.firmwareVersion
                    }
                }
            }

        }
    }



    inner class MyDeviceNotifyListener : DeviceNotifyListener() {
        override fun onDataResponse(resultEntity: DeviceNotifyRsp?) {
            if (resultEntity!!.status == BaseRspCmd.RESULT_OK) {
                BleOperateManager.getInstance().removeOthersListener()
                when (resultEntity.dataType) {
                    1 -> {
                        //手表心率测试
                    }
                    2 -> {
                        //手表血压测试
                    }
                    3 -> {
                        //手表血氧测试
                    }
                    4 -> {
                        //手表计步详情变化
                    }
                    5 -> {
                        //当天手表体温变化
                    }
                    7 -> {
                        //生成新的运动记录
                    }
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        try {
            if (!BluetoothUtils.isEnabledBluetooth(this)) {
                val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (ActivityCompat.checkSelfPermission(
                            this,
                            Manifest.permission.BLUETOOTH_CONNECT
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        return
                    }
                }
                startActivityForResult(intent, 300)
            }
        } catch (e: Exception) {
        }
        if (!hasBluetooth(this)) {
            requestBluetoothPermission(this, BluetoothPermissionCallback())
        }

        binding.tvName.text = DeviceManager.getInstance().deviceName
        requestAllPermission(this, OnPermissionCallback { permissions, all ->  })
    }

    inner class PermissionCallback : OnPermissionCallback {
        override fun onGranted(permissions: MutableList<String>, all: Boolean) {
            if (!all) {

            }else{
                startKtxActivity<DeviceBindActivity>()
            }
        }

        override fun onDenied(permissions: MutableList<String>, never: Boolean) {
            super.onDenied(permissions, never)
            if(never){
                XXPermissions.startPermissionActivity(this@MainActivity, permissions);
            }
        }

    }

    inner class BluetoothPermissionCallback : OnPermissionCallback {
        override fun onGranted(permissions: MutableList<String>, all: Boolean) {
            if (!all) {

            }
        }

        override fun onDenied(permissions: MutableList<String>, never: Boolean) {
            super.onDenied(permissions, never)
            if (never) {
                XXPermissions.startPermissionActivity(this@MainActivity, permissions)
            }
        }

    }

    inner class AllPermissionCallback : OnPermissionCallback {
        override fun onGranted(permissions: MutableList<String>, all: Boolean) {

        }

        override fun onDenied(permissions: MutableList<String>, never: Boolean) {
            super.onDenied(permissions, never)

        }
    }

}