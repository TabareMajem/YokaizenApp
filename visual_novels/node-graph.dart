import 'package:flutter/material.dart';
import '../models/dialogue_node.dart';
import 'dart:math';

class NodeGraphView extends StatefulWidget {
  final List<DialogueNode> nodes;
  final Function(DialogueNode) onNodeSelected;
  final String? activeNodeId;
  
  const NodeGraphView({
    Key? key,
    required this.nodes,
    required this.onNodeSelected,
    this.activeNodeId,
  }) : super(key: key);

  @override
  _NodeGraphViewState createState() => _NodeGraphViewState();
}

class _NodeGraphViewState extends State<NodeGraphView> {
  double _scale = 1.0;
  Offset _position = Offset.zero;
  Offset? _dragStart;
  Offset? _positionStart;
  Map<String, Offset> _nodePositions = {};
  GlobalKey _canvasKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _initializeNodePositions();
  }
  
  @override
  void didUpdateWidget(NodeGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If nodes were added, initialize their positions
    if (widget.nodes.length > oldWidget.nodes.length) {
      for (final node in widget.nodes) {
        if (!_nodePositions.containsKey(node.id)) {
          _placeNodeInAvailableSpace(node);
        }
      }
    }
    
    // If nodes were removed, clean up their positions
    if (widget.nodes.length < oldWidget.nodes.length) {
      final currentNodeIds = widget.nodes.map((node) => node.id).toSet();
      final nodesToRemove = _nodePositions.keys.where((id) => !currentNodeIds.contains(id)).toList();
      
      for (final id in nodesToRemove) {
        _nodePositions.remove(id);
      }
    }
  }
  
  void _initializeNodePositions() {
    // Calculate initial positions in a nice layout
    if (widget.nodes.isEmpty) return;
    
    // First node at center
    final firstNode = widget.nodes.first;
    _nodePositions[firstNode.id] = Offset.zero;
    
    for (int i = 1; i < widget.nodes.length; i++) {
      _placeNodeInAvailableSpace(widget.nodes[i]);
    }
  }
  
  void _placeNodeInAvailableSpace(DialogueNode node) {
    // Place new nodes in a circular pattern around the center
    final angle = (2 * pi / widget.nodes.length) * _nodePositions.length;
    final radius = 200.0;
    
    final x = radius * cos(angle);
    final y = radius * sin(angle);
    
    _nodePositions[node.id] = Offset(x, y);
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return const Center(child: Text('No dialogue nodes yet. Add your first node to get started!'));
    }
    
    return GestureDetector(
      onScaleStart: (details) {
        _dragStart = details.focalPoint;
        _positionStart = _position;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Handle panning
          if (details.scale == 1.0) {
            final delta = details.focalPoint - _dragStart!;
            _position = _positionStart! + delta / _scale;
          }
          // Handle zooming
          else {
            _scale = (_scale * details.scale).clamp(0.5, 2.0);
          }
        });
      },
      child: ClipRect(
        child: Container(
          color: Colors.grey.shade100,
          child: Stack(
            key: _canvasKey,
            children: [
              // Draw connection lines between nodes
              CustomPaint(
                painter: NodeConnectionPainter(
                  nodes: widget.nodes,
                  nodePositions: _nodePositions,
                  scale: _scale,
                  offset: _position,
                ),
                size: Size.infinite,
              ),
              
              // Position nodes
              ...widget.nodes.map((node) {
                final nodePosition = _nodePositions[node.id] ?? Offset.zero;
                final transformedPosition = nodePosition * _scale + _position;
                final isActive = node.id == widget.activeNodeId;
                
                return Positioned(
                  left: transformedPosition.dx,
                  top: transformedPosition.dy,
                  child: GestureDetector(
                    onPanStart: (details) {
                      // Select node when starting to drag it
                      widget.onNodeSelected(node);
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        // Move the node
                        final currentPos = _nodePositions[node.id] ?? Offset.zero;
                        _nodePositions[node.id] = currentPos + details.delta / _scale;
                      });
                    },
                    onTap: () => widget.onNodeSelected(node),
                    child: NodeWidget(
                      node: node,
                      isActive: isActive,
                    ),
                  ),
                );
              }).toList(),
              
              // Controls at bottom right
              Positioned(
                right: 16,
                bottom: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed: () => setState(() {
                            _scale = (_scale + 0.1).clamp(0.5, 2.0);
                          }),
                          tooltip: 'Zoom In',
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed: () => setState(() {
                            _scale = (_scale - 0.1).clamp(0.5, 2.0);
                          }),
                          tooltip: 'Zoom Out',
                        ),
                        IconButton(
                          icon: const Icon(Icons.center_focus_strong),
                          onPressed: _resetView,
                          tooltip: 'Reset View',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _resetView() {
    setState(() {
      _scale = 1.0;
      _position = Offset.zero;
    });
  }
}

class NodeConnectionPainter extends CustomPainter {
  final List<DialogueNode> nodes;
  final Map<String, Offset> nodePositions;
  final double scale;
  final Offset offset;
  
  NodeConnectionPainter({
    required this.nodes,
    required this.nodePositions,
    required this.scale,
    required this.offset,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final arrowPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    
    // Draw connections between nodes based on choices
    for (final node in nodes) {
      final startPos = (nodePositions[node.id] ?? Offset.zero) * scale + offset;
      final startPoint = startPos + const Offset(100, 70); // Bottom center of node
      
      for (final choice in node.choices) {
        // Find target node
        final targetNodeExists = nodes.any((n) => n.id == choice.targetNodeId);
        if (!targetNodeExists) continue;
        
        final endPos = (nodePositions[choice.targetNodeId] ?? Offset.zero) * scale + offset;
        final endPoint = endPos + const Offset(100, 30); // Top center of node
        
        // Draw the connection line
        canvas.drawLine(startPoint, endPoint, paint);
        
        // Draw arrow at the end
        _drawArrow(canvas, startPoint, endPoint, arrowPaint);
      }
    }
  }
  
  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final arrowSize = 10.0;
    final direction = (end - start).normalize();
    final arrowEnd = end - direction * arrowSize;
    
    // Calculate perpendicular vector
    final perpendicular = Offset(-direction.dy, direction.dx) * arrowSize / 2;
    
    // Draw triangle
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowEnd.dx + perpendicular.dx, arrowEnd.dy + perpendicular.dy)
      ..lineTo(arrowEnd.dx - perpendicular.dx, arrowEnd.dy - perpendicular.dy)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(NodeConnectionPainter oldDelegate) {
    return nodePositions != oldDelegate.nodePositions ||
        scale != oldDelegate.scale ||
        offset != oldDelegate.offset ||
        nodes.length != oldDelegate.nodes.length;
  }
}

class NodeWidget extends StatelessWidget {
  final DialogueNode node;
  final bool isActive;
  
  const NodeWidget({
    Key? key,
    required this.node,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: isActive
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            node.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.chat, '${node.lines.length}'),
              _buildInfoChip(Icons.call_split, '${node.choices.length}'),
              _buildInfoChip(Icons.equalizer, '${node.statChanges.length}'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
