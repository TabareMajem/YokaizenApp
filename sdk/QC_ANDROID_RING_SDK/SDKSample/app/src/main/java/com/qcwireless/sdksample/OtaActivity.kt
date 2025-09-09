package com.qcwireless.sdksample

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.oudmon.ble.base.bluetooth.BleOperateManager
import com.oudmon.ble.base.communication.DfuHandle
import com.qcwireless.sdksample.databinding.ActivityOtaBinding
import com.zlylib.fileselectorlib.FileSelector
import com.zlylib.fileselectorlib.utils.Const
import java.io.File


class OtaActivity : AppCompatActivity() {
    val REQUESTCODE_FROM_ACTIVITY = 1000
    private lateinit var binding: ActivityOtaBinding
    private var path=""
    private lateinit var dfuHandle:DfuHandle

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding=ActivityOtaBinding.inflate(layoutInflater)
        setContentView(binding.root)
        initView()
    }


    private fun initView(){
        binding.run {

        }

        setOnClickListener(binding.selectFile,binding.start){
            when(this){
                binding.selectFile->{
                    dfuHandle =  DfuHandle.getInstance()
//                    FileSelector.from(this@OtaActivity)
//                        // .onlyShowFolder()  //只显示文件夹
//                        //.onlySelectFolder()  //只能选择文件夹
////                         .isSingle // 只能选择一个
////                        .setMaxCount(5) //设置最大选择数
//                        .setFileTypes( "bin") //设置文件类型
//                        .setSortType(FileSelector.BY_NAME_ASC) //设置名字排序
//                        //.setSortType(FileSelector.BY_TIME_ASC) //设置时间排序
//                        //.setSortType(FileSelector.BY_SIZE_DESC) //设置大小排序
//                        //.setSortType(FileSelector.BY_EXTENSION_DESC) //设置类型排序
//                        .requestCode(1) //设置返回码
////                        .setTargetPath("/storage/emulated/0/") //设置默认目录
//                        .start();
                    val intent = Intent(Intent.ACTION_GET_CONTENT)
                    intent.type = "*/*"
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    startActivityForResult(intent, 0)
                }
                binding.start->{
                    //dfu 升级实例
                    //初始化回调
                    dfuHandle.initCallback()
                    //DFU 文件校验,path 固件文件路径
                    if (dfuHandle.checkFile(path)) {
                        dfuHandle.start(dfuOpResult)
                    }else{

                    }

                }
            }
        }
    }

    //dfuOpResult 回调说明
    private val dfuOpResult: DfuHandle.IOpResult = object : DfuHandle.IOpResult {
        override fun onActionResult(type: Int, errCode: Int) {
            if (errCode == DfuHandle.RSP_OK) {
                when (type) {
                    1 -> dfuHandle.init()
                    2 -> dfuHandle.sendPacket()
                    3 -> dfuHandle.check()
                    4 -> {
                        //升级成功,等待设备重启
                        dfuHandle.endAndRelease()
                    }
                }
            } else {
                //升级异常或者失败
            }
        }

        override fun onProgress(percent: Int) {
            //文件升级进度
            runOnUiThread {
                binding.value.text= "$percent%"
            }

        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode == Activity.RESULT_OK) {
            val uri: Uri? = data?.data
            if (uri != null) {
                 path = GetFilePathFromUri.getFileAbsolutePath(this, uri)
                if (path.endsWith(".bin")) {
                    binding.selectFilePath.text=path
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        BleOperateManager.getInstance().unBindDevice()
    }

}