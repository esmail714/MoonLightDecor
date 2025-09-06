import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../models/lost_item.dart';
import 'lost_item_form_screen.dart';
import 'booking_details_screen.dart';

class LostItemsScreen extends StatefulWidget {
  const LostItemsScreen({super.key});

  @override
  State<LostItemsScreen> createState() => _LostItemsScreenState();
}

class _LostItemsScreenState extends State<LostItemsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadLostItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المفقودات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookingProvider>().loadLostItems();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث في المفقودات',
                hintText: 'الوصف أو المكان',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                context.read<BookingProvider>().searchLostItems(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingLostItems) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.lostItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.find_in_page,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.lostItemsSearchQuery.isEmpty
                              ? 'لا توجد مفقودات مسجلة بعد'
                              : 'لا توجد نتائج للبحث',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.lostItemsSearchQuery.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _addNewLostItem,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة مفقود جديد'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.lostItems.length,
                  itemBuilder: (context, index) {
                    final lostItem = provider.lostItems[index];
                    return _buildLostItemCard(lostItem);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewLostItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLostItemCard(LostItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewLostItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(item.dateFound),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.locationFound,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (item.bookingId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'مرتبط بالحجز: ${item.bookingId}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, item),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(LostItemStatus status) {
    Color color;
    switch (status) {
      case LostItemStatus.found:
        color = Colors.green;
        break;
      case LostItemStatus.returned:
        color = Colors.blue;
        break;
      case LostItemStatus.pending:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addNewLostItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LostItemFormScreen(),
      ),
    ).then((_) => context.read<BookingProvider>().loadLostItems());
  }

  void _viewLostItemDetails(LostItem item) {
    // يمكن هنا عرض تفاصيل أكثر للمفقود أو الانتقال لشاشة تفاصيل الحجز المرتبط
    if (item.bookingId != null) {
      // جلب تفاصيل الحجز وعرضها
      context.read<BookingProvider>().getBookingById(item.bookingId!).then((booking) {
        if (mounted) {
          if (booking != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailsScreen(booking: booking),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("لم يتم العثور على الحجز المرتبط")), 
            );
          }
        }
      });
    } else {
      // يمكن عرض نافذة منبثقة بتفاصيل المفقود فقط
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تفاصيل المفقود'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الوصف: ${item.description}'),
              Text('تاريخ العثور: ${_formatDate(item.dateFound)}'),
              Text('مكان العثور: ${item.locationFound}'),
              Text('الحالة: ${item.status.displayName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    }
  }

  void _handleMenuAction(String action, LostItem item) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LostItemFormScreen(lostItem: item),
          ),
        ).then((_) => context.read<BookingProvider>().loadLostItems());
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _showDeleteConfirmation(LostItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المفقود: ${item.description}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingProvider>().deleteLostItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم حذف المفقود بنجاح")),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

