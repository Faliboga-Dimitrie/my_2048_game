import 'package:flutter/material.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/game/model/board.dart';
import 'package:my_2048_game/features/game/view_model/board_vm.dart';
import 'package:my_2048_game/features/local_play/provider/user_provider.dart';
import 'package:provider/provider.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  final TextEditingController _sizeController = TextEditingController(text: '4');
  BoardViewModel? _viewModel;

  @override
  void dispose() {
    _sizeController.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    final db = context.read<AppDatabase>();
    final user = db.getUserByUsername(context.read<UserSession>().currentUser!.username);
    final parsed = int.tryParse(_sizeController.text) ?? 4;
    final size = parsed.clamp(2, 8);

    int? userId = (await user)?.id;

    if (userId == null) {
      // This should not happen, as we come from local user selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not found')),
      );
      return;
    }

    final vm = BoardViewModel(
      db: db,
      userId: userId,
      initialSize: size,
    );

    await vm.newGame();

    setState(() => _viewModel = vm);
  }

  void _resetSizeSelection() {
    _viewModel?.dispose();
    _viewModel = null;
    _sizeController.text = '4';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<UserSession>();
    final username = session.currentUser?.username ?? 'Unknown';

    // STEP 1: if no viewModel yet, ask for board size
    if (_viewModel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Choose Board Size'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Player: $username',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter board size',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Size (e.g. 4 for 4×4)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        child: const Text('Start Game'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // STEP 2: once we have a viewModel, render the board
    final vm = _viewModel!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        actions: [
          IconButton(
            tooltip: 'Change board size',
            onPressed: _resetSizeSelection,
            icon: const Icon(Icons.grid_on),
          ),
          IconButton(
            tooltip: 'New game',
            onPressed: vm.newGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player: $username',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${vm.score}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (vm.isGameOver)
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _BoardView(
                      board: vm.board,
                      onMove: vm.onMove,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Separate widget for the board grid.
/// It wraps the grid in a GestureDetector so you can use swipe input later.
class _BoardView extends StatelessWidget {
  const _BoardView({
    required this.board,
    required this.onMove,
  });

  final Board board;
  final void Function(Direction) onMove;

  @override
  Widget build(BuildContext context) {
    final size = board.size;

    return GestureDetector(
      // TODO: replace with your gyroscope or proper swipe detection later.
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        if (velocity.dx.abs() > velocity.dy.abs()) {
          // horizontal swipe
          if (velocity.dx > 0) {
            onMove(Direction.right);
          } else {
            onMove(Direction.left);
          }
        } else {
          // vertical swipe
          if (velocity.dy > 0) {
            onMove(Direction.down);
          } else {
            onMove(Direction.up);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: size * size,
            itemBuilder: (context, index) {
              final row = index ~/ size;
              final col = index % size;
              final tile = board.tileAt(row, col);

              return _TileView(value: tile.value);
            },
          ),
        ),
      ),
    );
  }
}

class _TileView extends StatelessWidget {
  const _TileView({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEmpty ? Colors.grey.shade200 : Colors.orange.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isEmpty
            ? const SizedBox.shrink()
            : Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
