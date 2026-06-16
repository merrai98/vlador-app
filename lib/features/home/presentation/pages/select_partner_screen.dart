import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:valdor_application/features/home/presentation/pages/partner_details_screen.dart';
import '../../../../core/helpers/hive_manager.dart';
import '../../../../core/widgets/design/design_widgets.dart';
import '../../data/models/models.dart';

class SelectPartnerScreen extends StatefulWidget {
  const SelectPartnerScreen({super.key});

  @override
  State<SelectPartnerScreen> createState() => _SelectPartnerScreenState();
}

class _SelectPartnerScreenState extends State<SelectPartnerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<PartnerModel> _allPartners = [];
  List<PartnerModel> _filteredPartners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    final partners = await HiveManager().getAllPartners();
    setState(() {
      _allPartners = partners;
      _filteredPartners = partners;
      _isLoading = false;
    });
  }

  void _filterPartners(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPartners = _allPartners;
      } else {
        final String lowercaseQuery = query.toLowerCase().trim();
        final List<String> queryWords = lowercaseQuery.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

        _filteredPartners = _allPartners.where((partner) {
          final String name = partner.partnerName?.toLowerCase() ?? "";
          
          if (name.contains(lowercaseQuery)) return true;

          final List<String> nameWords = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
          if (nameWords.isEmpty) return false;

          if (queryWords.isNotEmpty) {
            bool allQueryWordsMatched = true;
            int currentNameWordIndex = 0;

            for (var qWord in queryWords) {
              bool foundMatch = false;
              while (currentNameWordIndex < nameWords.length) {
                if (nameWords[currentNameWordIndex].startsWith(qWord)) {
                  foundMatch = true;
                  currentNameWordIndex++; 
                  break;
                }
                currentNameWordIndex++;
              }
              if (!foundMatch) {
                allQueryWordsMatched = false;
                break;
              }
            }
            if (allQueryWordsMatched) return true;
          }

          final String initials = nameWords.map((w) => w[0]).join();
          if (initials.contains(lowercaseQuery.replaceAll(' ', ''))) return true;

          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEEF1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'select_partner'.tr(),
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: const Center(child: NetworkStatusBadge()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPartners,
                decoration: InputDecoration(
                  hintText: 'search_partner'.tr(),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0B5E63)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF0B5E63), width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPartners.isEmpty
                    ? Center(child: Text('no_partners'.tr()))
                    : RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        trackColor: const Color(0xFF0B5E63).withOpacity(0.05),
                        thumbColor: const Color(0xFF0B5E63).withOpacity(0.4),
                        radius: Radius.circular(20.r),
                        thickness: 6.w,
                        padding: EdgeInsets.only(right: 2.w),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: _filteredPartners.length,
                          itemBuilder: (context, index) {
                            return _buildPartnerCard(_filteredPartners[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(PartnerModel partner) {
    final String initial = (partner.partnerName?.isNotEmpty ?? false)
        ? partner.partnerName![0].toUpperCase()
        : "?";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDetailsScreen(partner: partner),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B5E63), Color(0xFF11878F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.partnerName ?? "",
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        "ID: ${partner.partnerId}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 18.h),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
