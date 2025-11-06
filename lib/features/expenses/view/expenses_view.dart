import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/footer_widget.dart';
import '../../../data/models/expense_model.dart';
import '../controller/expenses_controller.dart';

class ExpensesView extends GetView<ExpensesController> {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildExpensesDashboard()),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            height: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title
                Text(
                  'Expenses Management',
                  style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // Date Range Picker
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'November 2025',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16.w),
                // Add Expense Button
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddExpenseDialog(Get.context!),
                        icon: Icon(Icons.add, size: 18.sp),
                        label: Text(
                          'Add Expense',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 14.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesDashboard() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(),
            SizedBox(height: 32.h),

            // Charts Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Trend Chart
                Expanded(flex: 2, child: _buildExpenseTrendChart()),
                SizedBox(width: 24.w),
                // Category Breakdown
                Expanded(flex: 1, child: _buildCategoryBreakdown()),
              ],
            ),
            SizedBox(height: 32.h),

            // Recent Expenses Table
            _buildRecentExpensesTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final total = controller.totalExpenses;
      final monthly = controller.monthlyExpenses;
      final average = controller.averageDaily;
      final topCat = controller.topCategory;
      final topPerc = controller.topCategoryPercentage;

      return Row(
        children: [
          _buildSummaryCard(
            'Total Expenses',
            'PKR ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            Icons.account_balance_wallet,
            Colors.red.shade600,
            '${controller.expenses.length} expenses',
          ),
          SizedBox(width: 24.w),
          _buildSummaryCard(
            'Monthly Expenses',
            'PKR ${monthly.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            Icons.calendar_month,
            Colors.orange.shade600,
            'Current month',
          ),
          SizedBox(width: 24.w),
          _buildSummaryCard(
            'Average Daily',
            'PKR ${average.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            Icons.trending_up,
            Colors.blue.shade600,
            'Based on data',
          ),
          SizedBox(width: 24.w),
          _buildSummaryCard(
            'Top Category',
            topCat,
            Icons.category,
            Colors.green.shade600,
            '${topPerc.toStringAsFixed(1)}% of total',
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, (1 - opacity) * 20),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(icon, color: color, size: 24.sp),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 20.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseTrendChart() {
    return Obx(() {
      final data = controller.chartData;
      final maxValue = data.isEmpty
          ? 0.0
          : data
                .map((e) => e['value'] as double)
                .reduce((a, b) => a > b ? a : b);

      return Container(
        height: 400.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Trend',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                // Period selection buttons
                Wrap(
                  spacing: 8.w,
                  children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((
                    period,
                  ) {
                    final isSelected =
                        controller.selectedPeriod.value == period;
                    return ElevatedButton(
                      onPressed: () => controller.setPeriod(period),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : Colors.grey[100],
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        elevation: isSelected ? 2 : 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        period,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'No data available for ${controller.selectedPeriod.value.toLowerCase()} view',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Column(
                        children: [
                          // Value labels row
                          SizedBox(
                            height: 25.h,
                            child: Row(
                              children: data.map((item) {
                                final value = item['value'] as double;
                                return Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      'PKR ${value.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 8.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Chart area
                          SizedBox(
                            height: 120.h,
                            child: CustomPaint(
                              painter: LineChartPainter(data, maxValue),
                              child: Container(),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // X-axis labels row
                          SizedBox(
                            height: 35.h,
                            child: Row(
                              children: data.map((item) {
                                return Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      item['label'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.sp,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryBreakdown() {
    return Obx(() {
      final categories = controller.categoryBreakdown;

      return Container(
        height: 400.h,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        'No expenses yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset((1 - opacity) * 20, 0),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: category['color'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category['name'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex:
                                                      ((category['percentage']
                                                                  as double) *
                                                              10)
                                                          .toInt(),
                                                  child: Container(
                                                    height: 4.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (category['color']
                                                                  as Color)
                                                              .withOpacity(0.3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2.r,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex:
                                                      100 -
                                                      ((category['percentage']
                                                                  as double) *
                                                              10)
                                                          .toInt(),
                                                  child: Container(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'PKR ${(category['amount'] as double).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '${(category['percentage'] as double).toStringAsFixed(1)}%',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRecentExpensesTable() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Expenses',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list, size: 18.sp),
                  label: Text(
                    'Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 400.h,
              child: DataTable2(
                columnSpacing: 8.w,
                horizontalMargin: 8.w,
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                headingRowHeight: 56.h,
                dataRowHeight: 60.h,
                showCheckboxColumn: false,
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                columns: [
                  DataColumn2(
                    label: Text(
                      'Date',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text(
                      'Amount',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text(
                      'Status',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text(
                      'Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    size: ColumnSize.M,
                  ),
                ],
                rows: List<DataRow>.generate(controller.expenses.length, (
                  index,
                ) {
                  final expense = controller.expenses[index];
                  final isEvenRow = index % 2 == 0;

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.primary.withOpacity(0.05);
                      }
                      return isEvenRow ? Colors.grey[50] : Colors.white;
                    }),
                    cells: [
                      DataCell(
                        Text(
                          _formatDate(
                            expense.date.toIso8601String().split('T')[0],
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              expense.category,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            expense.category,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(expense.category),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          expense.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'PKR ${expense.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              expense.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            expense.status,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(expense.status),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _editExpense(expense),
                              icon: Icon(
                                Icons.edit,
                                size: 18.sp,
                                color: Colors.blue,
                              ),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () => _deleteExpense(expense),
                              icon: Icon(
                                Icons.delete,
                                size: 18.sp,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salaries':
        return Colors.blue;
      case 'utilities':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'supplies':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddExpenseDialog(BuildContext context) {
    Get.dialog(AddExpenseDialog(), barrierDismissible: false);
  }

  void _editExpense(ExpenseModel expense) {
    Get.dialog(AddExpenseDialog(expense: expense), barrierDismissible: false);
  }

  void _deleteExpense(ExpenseModel expense) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Delete Expense',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this expense?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await controller.deleteExpense(expense.id!);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Expense deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;

  LineChartPainter(this.data, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxValue == 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value'] as double;
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (value / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Draw data point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AddExpenseDialog extends StatefulWidget {
  final ExpenseModel? expense;
  const AddExpenseDialog({super.key, this.expense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Salaries';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogScaleAnimation;
  late Animation<double> _dialogOpacityAnimation;

  late AnimationController _fieldAnimationController;
  late List<Animation<double>> _fieldAnimations;

  final List<String> _categories = [
    'Salaries',
    'Utilities',
    'Maintenance',
    'Supplies',
    'Transportation',
    'Marketing',
    'Equipment',
    'Rent',
    'Insurance',
    'Others',
  ];

  @override
  void initState() {
    super.initState();

    // Populate fields if editing
    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
    }

    // Dialog entrance animation
    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _dialogScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _dialogOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dialogAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Staggered field animations
    _fieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fieldAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fieldAnimationController,
          curve: Interval(
            index * 0.1,
            0.6 + index * 0.1,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    // Start animations
    _dialogAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fieldAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dialogAnimationController.dispose();
    _fieldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dialogAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _dialogScaleAnimation.value,
          child: Opacity(
            opacity: _dialogOpacityAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 520.w,
                constraints: BoxConstraints(maxHeight: 650.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.03,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.5,
                              colors: [AppColors.primary, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with animated icon
                        Container(
                          padding: EdgeInsets.all(28.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.accent.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Animated icon with glow
                              Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.accent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, opacity, child) {
                                        return Opacity(
                                          opacity: opacity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              (1 - opacity) * 20,
                                            ),
                                            child: Text(
                                              widget.expense != null
                                                  ? 'Edit Expense'
                                                  : 'Add New Expense',
                                              style: GoogleFonts.poppins(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 4.h),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, opacity, child) {
                                        return Opacity(
                                          opacity: opacity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              (1 - opacity) * 15,
                                            ),
                                            child: Text(
                                              'Track your organizational expenses',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13.sp,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form with staggered animations
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(28.w),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Field
                                  AnimatedBuilder(
                                    animation: _fieldAnimations[0],
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fieldAnimations[0].value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            (1 - _fieldAnimations[0].value) *
                                                30,
                                          ),
                                          child: _buildCategoryField(),
                                        ),
                                      );
                                    },
                                  ),

                                  // Description Field
                                  AnimatedBuilder(
                                    animation: _fieldAnimations[1],
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fieldAnimations[1].value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            (1 - _fieldAnimations[1].value) *
                                                30,
                                          ),
                                          child: _buildDescriptionField(),
                                        ),
                                      );
                                    },
                                  ),

                                  // Amount Field
                                  AnimatedBuilder(
                                    animation: _fieldAnimations[2],
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fieldAnimations[2].value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            (1 - _fieldAnimations[2].value) *
                                                30,
                                          ),
                                          child: _buildAmountField(),
                                        ),
                                      );
                                    },
                                  ),

                                  // Date Field
                                  AnimatedBuilder(
                                    animation: _fieldAnimations[3],
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fieldAnimations[3].value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            (1 - _fieldAnimations[3].value) *
                                                30,
                                          ),
                                          child: _buildDateField(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Buttons with enhanced styling
                        Container(
                          padding: EdgeInsets.all(28.w),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[100]!,
                                width: 1.5,
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24.r),
                              bottomRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Cancel Button
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 50.h,
                                  child: OutlinedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14.r,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey[50],
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),

                              // Save Button
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 50.h,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _saveExpense,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14.r,
                                        ),
                                      ),
                                      elevation: _isLoading ? 0 : 3,
                                      shadowColor: AppColors.primary
                                          .withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add, size: 18.sp),
                                              SizedBox(width: 8.w),
                                              Text(
                                                widget.expense != null
                                                    ? 'Update Expense'
                                                    : 'Add Expense',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Expense Category',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 16.h,
              ),
              prefixIcon: Icon(
                Icons.grid_view,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Enter detailed expense description...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 16.h,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Icon(Icons.notes, color: AppColors.primary, size: 20.sp),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Description is required';
              }
              if (value.length < 5) {
                return 'Description must be at least 5 characters';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Amount (PKR)',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 16.h,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 16.w, right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'PKR',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Amount is required';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Date',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        InkWell(
          onTap: _isLoading
              ? null
              : () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salaries':
        return Colors.blue;
      case 'utilities':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'supplies':
        return Colors.red;
      case 'transportation':
        return Colors.purple;
      case 'marketing':
        return Colors.pink;
      case 'equipment':
        return Colors.teal;
      case 'rent':
        return Colors.indigo;
      case 'insurance':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final expense = ExpenseModel(
        id: widget.expense?.id,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        status: widget.expense?.status ?? 'Paid',
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.expense != null
          ? await Get.find<ExpensesController>().updateExpense(expense)
          : await Get.find<ExpensesController>().addExpense(expense);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Get.back();
      }
    }
  }
}
