import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'edit_product_screen.dart';

class ProductCatalogFragment extends StatefulWidget {
  const ProductCatalogFragment({super.key});

  @override
  State<ProductCatalogFragment> createState() => _ProductCatalogFragmentState();
}

class _ProductCatalogFragmentState extends State<ProductCatalogFragment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Future<void> _loadProducts() async {
  //   try {
  //     setState(() => _isLoading = true);

  //     final querySnapshot = await _firestore
  //         .collection('products')
  //         .where('ordinabile', isEqualTo: true)
  //         .get();

  //     _products = querySnapshot.docs
  //         .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
  //         .toList();

  //     setState(() => _isLoading = false);
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Errore nel caricamento prodotti: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Prodotti'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Usa un Consumer qui o accedi al ViewModel se sei già dentro un builder
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              // Mostra il pulsante solo se l'utente è un admin
              if (authViewModel.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddProductDialog();
                  },
                );
              } else {
                // Altrimenti non mostrare nulla
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Usa i prodotti dal ViewModel invece di caricarli separatamente
          final prodotti = authViewModel.isAdmin
              ? authViewModel.prodotti
              : authViewModel.prodottiOrdinabili;

          final isLoading = authViewModel.isLoading;

          return Column(
            children: [
              // Barra di ricerca
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca prodotti...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // Informazioni di debug
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Caricati ${prodotti.length} prodotti da Firestore',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Lista prodotti
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _getFilteredProducts(prodotti).isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Nessun prodotto disponibile',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'I prodotti verranno caricati da Firestore',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => authViewModel.refreshAllData(),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _getFilteredProducts(prodotti).length,
                              itemBuilder: (context, index) {
                                final product = _getFilteredProducts(prodotti)[index];
                                return _buildProductCard(product);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Product> _getFilteredProducts(List<Product> prodotti) {
    if (_searchQuery.isEmpty) return prodotti;

    return prodotti.where((product) {
      return product.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             product.descrizione.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildProductCard(Product product) {
    final authViewModel = context.read<AuthViewModel>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: (){
          if (authViewModel.isAdmin) {
            // Se è admin, naviga alla schermata di modifica
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProductScreen(product: product),
              ),
            );
          } else {
            // Se è un utente normale, mostra i dettagli come prima
            _showProductDetails(product);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine prodotto
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.grey[200],
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Dettagli prodotto
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.descrizione,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€ ${product.importo.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Pz: ${product.numeroPezzi}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Descrizione:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(product.descrizione),
            const SizedBox(height: 8),
            Text(
              'Prezzo: €${product.importo.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text('Pezzi disponibili: ${product.numeroPezzi}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementare ordine prodotto
              _orderProduct(product);
            },
            child: const Text('Ordina'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    // TODO: Implementare dialog per aggiungere prodotto (solo admin)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Prodotto'),
        content: const Text('Funzionalità in sviluppo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _orderProduct(Product product) {
    // TODO: Implementare logica ordine
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ordinato: ${product.nome}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
