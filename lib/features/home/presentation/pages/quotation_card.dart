import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import '../../data/models/models.dart';
import 'quotation_details_screen.dart';

class QuotationCard extends StatelessWidget {
  final QuotationModel quotation;

  const QuotationCard({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuotationDetailsScreen(quotation: quotation),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Partner Name Layout and Total Value
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quotation.partnerName ?? "",
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Row(
                    children: [
                      Text(
                        'total'.tr(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        ': ${(quotation.totalCount ??0).toInt()}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Row 2: Document Indexing Number, Timestamps, and Status Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        quotation.name ?? "",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          '|',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                      Text(
                        quotation.createDate ?? "-",
                        style: TextStyle(color: Colors.black54, fontSize: 13.sp),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.access_time, size: 14.r, color: Colors.black45),
                    ],
                  ),

                  // Status Badge styling container (state-aware, like the prototype)
                  Builder(
                    builder: (context) {
                      final state = (quotation.state ?? '').toLowerCase();
                      Color bg;
                      Color fg;
                      if (state == 'draft') {
                        bg = const Color(0xFFE1EFEF); // teal wash
                        fg = const Color(0xFF084146);
                      } else if (state == 'sale' ||
                          state == 'done' ||
                          state == 'confirmed') {
                        bg = const Color(0xFFF4E7E7); // lock wash
                        fg = const Color(0xFF9A3B3B);
                      } else {
                        bg = const Color(0xFFF6ECD8); // amber wash (queued / other)
                        fg = const Color(0xFF8D621A);
                      }
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 14.w,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          quotation.state ?? "",
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
