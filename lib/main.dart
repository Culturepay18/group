import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage stockage = FlutterSecureStorage();

const List<ProductItem> productItems = [
  ProductItem(
    id: 'savon-01',
    title: 'Savon Bio',
    imagePath: 'assets/images/sp1.png',
    imageLink: 'https://picsum.photos/seed/savonbio/700/450',
    isAsset: true,
  ),
  ProductItem(
    id: 'savon-02',
    title: 'Savon Karite',
    imagePath: 'assets/images/sp2.png',
    imageLink: 'https://picsum.photos/seed/savonkarite/700/450',
    isAsset: true,
  ),
  ProductItem(
    id: 'savon-03',
    title: 'Savon Citron',
    imagePath: 'assets/images/sp3.png',
    imageLink: 'https://picsum.photos/seed/savoncitron/700/450',
    isAsset: true,
  ),
  ProductItem(
    id: 'savon-04',
    title: 'Savon Doux',
    imagePath: 'assets/images/sp5.png',
    imageLink: 'https://picsum.photos/seed/savondoux/700/450',
    isAsset: true,
  ),
  ProductItem(
    id: 'network-01',
    title: 'Parfum Fresh',
    imagePath: 'https://picsum.photos/seed/parfumfresh/700/450',
    imageLink: 'https://picsum.photos/seed/parfumfresh/700/450',
    isAsset: false,
  ),
  ProductItem(
    id: 'network-02',
    title: 'Creme Nature',
    imagePath: 'https://picsum.photos/seed/cremenature/700/450',
    imageLink: 'https://picsum.photos/seed/cremenature/700/450',
    isAsset: false,
  ),
];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EBoutikoo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A68E2)),
        useMaterial3: true,
      ),
      home: const ProductHomeScreen(),
    );
  }
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.imageLink,
    required this.isAsset,
  });

  final String id;
  final String title;
  final String imagePath;
  final String imageLink;
  final bool isAsset;
}

class ProductHomeScreen extends StatefulWidget {
  const ProductHomeScreen({super.key});

  @override
  State<ProductHomeScreen> createState() => _ProductHomeScreenState();
}

class _ProductHomeScreenState extends State<ProductHomeScreen> {
  Future<void> _buyProduct(ProductItem product) async {
    final String key =
        'achat_${DateTime.now().millisecondsSinceEpoch}_${product.id}';

    try {
      await stockage.write(key: key, value: product.imageLink);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Echec sauvegarde: $error')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.title} achte ak sikses.')),
    );
  }

  void _openPurchaseList() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PurchaseListScreen(),
      ),
    );
  }

  Widget _buildImage(ProductItem product) {
    if (product.isAsset) {
      return Image.asset(
        product.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Imaj asset pa chaje.'));
        },
      );
    }

    return Image.network(
      product.imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        final int? total = progress.expectedTotalBytes;
        final int loaded = progress.cumulativeBytesLoaded;
        final double? value = total != null ? loaded / total : null;
        return Center(child: CircularProgressIndicator(value: value));
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text('Imaj rezo pa disponib.'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('EBoutikoo'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _openPurchaseList,
            child: const Text(
              'Lis Achte',
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: productItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.64,
        ),
        itemBuilder: (context, index) {
          final ProductItem product = productItems[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildImage(product)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                  child: Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _buyProduct(product),
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Achte'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  late Future<List<String>> _linksFuture;

  @override
  void initState() {
    super.initState();
    _linksFuture = _loadPurchasedLinks();
  }

  Future<List<String>> _loadPurchasedLinks() async {
    final Map<String, String> allValues;
    try {
      allValues = await stockage.readAll();
    } catch (error) {
      throw Exception('Lektir stokaj echwe: $error');
    }

    final List<MapEntry<String, String>> purchases = allValues.entries
        .where((entry) => entry.key.startsWith('achat_'))
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return purchases.map((entry) => entry.value).toList();
  }

  void _reload() {
    setState(() {
      _linksFuture = _loadPurchasedLinks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Lis Achte'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _linksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gen yon ere pandan lekti done yo.'));
          }

          final List<String> links = snapshot.data ?? <String>[];
          if (links.isEmpty) {
            return const Center(child: Text('Pa gen acha anrejistre pou kounye a.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: links.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final String link = links[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acha #${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        link,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          link,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('Preview pa disponib pou lyen sa a.'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
