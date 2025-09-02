import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'edit_product_screen.dart';
import 'add_product_screen.dart';


class ProductCatalogFragment extends StatefulWidget {
  const ProductCatalogFragment({super.key});

  @override
  State<ProductCatalogFragment> createState() => _ProductCatalogFragmentState();
}

class _ProductCatalogFragmentState extends State<ProductCatalogFragment> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Prodotti'),
        actions: [
          // Mostra il pulsante solo se l'utente è un admin
          if (authViewModel.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra di ricerca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cerca prodotti...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Lista prodotti
          Expanded(
            child: Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                final prodotti = viewModel.isAdmin
                    ? viewModel.prodotti
                    : viewModel.prodottiOrdinabili;

                if (viewModel.isLoading && prodotti.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = _getFilteredProducts(prodotti);

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('Nessun prodotto trovato.'));
                }

                return RefreshIndicator(
                  onRefresh: () => viewModel.refreshAllData(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  List<Product> _getFilteredProducts(List<Product> prodotti) {
    if (_searchQuery.isEmpty) return prodotti;
    final query = _searchQuery.toLowerCase();
    return prodotti.where((product) {
      return product.nome.toLowerCase().contains(query) ||
          product.descrizione.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final authViewModel = context.read<AuthViewModel>();
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Per arrotondare l'immagine
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (authViewModel.isAdmin) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditProductScreen(product: product)),
            );
          } else {
            _showProductDetails(context, product);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              )
                  : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.nome, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.descrizione, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('€ ${product.prezzo.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Pz: ${product.numeroPezzi}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    // Questa funzione solo per l'utente normale,
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.nome),
        content: Text(product.descrizione),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}