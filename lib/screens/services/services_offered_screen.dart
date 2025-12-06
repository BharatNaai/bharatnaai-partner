import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:partner_app/core/constants/app_colors.dart';
import 'package:partner_app/models/service_offering.dart';
import 'package:partner_app/repositories/service_repository.dart';
import 'package:partner_app/widgets/service_offering_dialog.dart';

class ServicesOfferedScreen extends StatefulWidget {
  const ServicesOfferedScreen({super.key});

  @override
  State<ServicesOfferedScreen> createState() => _ServicesOfferedScreenState();
}

class _ServicesOfferedScreenState extends State<ServicesOfferedScreen> {
  List<ServiceOffering> _services = <ServiceOffering>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = ServiceRepository.instance;
      final list = await repo.getServices();
      if (!mounted) return;
      setState(() {
        _services = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load services. Please try again.'),
        ),
      );
    }
  }

  Future<void> _editService(ServiceOffering service) async {
    final ServiceOffering? updated = await showServiceOfferingDialog(
      context: context,
      initialService: service,
    );

    if (updated == null) {
      return;
    }

    final repo = ServiceRepository.instance;

    try {
      await repo.updateService(updated);
      await _loadServices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update service. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteService(ServiceOffering service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: Text(
            'Are you sure you want to delete "${service.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final repo = ServiceRepository.instance;
    try {
      await repo.deleteService(service.id);
      await _loadServices();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service deleted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete service. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services I Offer'),
      ),
      backgroundColor: AppColors.loginBackgroundEnd,
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _services.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No services added yet.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.loginSubtitleText,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final service = _services[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10182840),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\u20b9${service.cost}',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _editService(service),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _deleteService(service),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: AppColors.loginSubtitleText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.averageTime} mins',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppColors.loginSubtitleText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.star_outline,
                            size: 16,
                            color: AppColors.loginSubtitleText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.experience} yrs exp',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppColors.loginSubtitleText,
                            ),
                          ),
                        ],
                      ),
                      if (service.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          service.notes,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
                  ),
      ),
    );
  }
}
