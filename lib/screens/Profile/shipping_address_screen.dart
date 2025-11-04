import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_event.dart';
import 'package:heaven_book_app/bloc/address/address_state.dart';
import 'package:heaven_book_app/model/tag_address.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/widgets/address_card_widget.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  // Controllers for edit dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _showEditDialog(
    int addressId,
    String currentTagName,
    String currentName,
    String currentPhone,
    String currentAddress,
    bool isDefault,
    int currentTagId,
  ) {
    // Get tag list from state
    final addressState = context.read<AddressBloc>().state;
    List<TagAddress> tagList = [];
    if (addressState is AddressLoaded) {
      tagList = addressState.tagAddress;
    }

    // Set initial values for controllers với dữ liệu thật
    _nameController.text = currentName;
    _phoneController.text = currentPhone;
    _addressController.text = currentAddress;

    // State for dialog
    bool tempIsDefault = isDefault;
    int selectedTagId = currentTagId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        //'Edit Address',
                        'Chỉnh sửa địa chỉ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Form fields
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Tag Dropdown
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: DropdownButtonFormField<int>(
                                  value: selectedTagId,
                                  decoration: InputDecoration(
                                    //labelText: 'Address Tag',
                                    labelText: 'Tên địa chỉ',
                                    prefixIcon: Icon(
                                      Icons.local_offer,
                                      color: AppColors.primaryDark,
                                    ),
                                    labelStyle: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                  ),
                                  items:
                                      tagList.map((tag) {
                                        return DropdownMenuItem<int>(
                                          value: tag.id,
                                          child: Text(
                                            tag.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedTagId = value;
                                      });
                                    }
                                  },
                                  dropdownColor: Colors.white,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 16),

                          _buildEditTextField(
                            controller: _nameController,
                            //label: 'Recipient Name',
                            label: 'Tên người nhận',
                            icon: Icons.person,
                            //hint: 'Enter full name',
                            hint: 'Nhập tên đầy đủ',
                          ),

                          SizedBox(height: 16),

                          _buildEditTextField(
                            controller: _phoneController,
                            //label: 'Phone Number',
                            label: 'Số điện thoại',
                            icon: Icons.phone,
                            //hint: 'Enter phone number',
                            hint: 'Nhập số điện thoại',
                            keyboardType: TextInputType.phone,
                          ),

                          SizedBox(height: 16),

                          _buildEditTextField(
                            controller: _addressController,
                            //label: 'Full Address',
                            label: 'Địa chỉ đầy đủ',
                            icon: Icons.location_on,
                            //hint: 'Enter complete address',
                            hint: 'Nhập địa chỉ đầy đủ',
                            maxLines: 3,
                          ),

                          SizedBox(height: 20),

                          // Set as default option
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColors.primaryDark,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    //'Set as Default Address',
                                    'Đặt làm địa chỉ mặc định',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                StatefulBuilder(
                                  builder: (
                                    BuildContext context,
                                    StateSetter setState,
                                  ) {
                                    return Switch(
                                      value: tempIsDefault,
                                      onChanged: (value) {
                                        setState(() {
                                          tempIsDefault = value;
                                        });
                                      },
                                      activeColor: AppColors.primaryDark,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primaryDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            //'Cancel',
                            'Hủy',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () => _saveEditedAddress(
                                addressId,
                                tempIsDefault,
                                selectedTagId,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            //'Save Changes',
                            'Lưu thay đổi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryDark),
          labelStyle: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  void _saveEditedAddress(int addressId, bool isDefault, int tagId) {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      //_showErrorSnackBar('Please enter recipient name');
      _showErrorSnackBar('Vui lòng nhập tên người nhận');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      //_showErrorSnackBar('Please enter phone number');
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      //_showErrorSnackBar('Please enter address');
      _showErrorSnackBar('Vui lòng nhập địa chỉ');
      return;
    }

    // Dispatch update event
    context.read<AddressBloc>().add(
      UpdateAddress(
        addressId: addressId,
        recipientName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        tagId: tagId,
        isDefault: isDefault,
      ),
    );

    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            //Text('Address updated successfully'),
            Text('Cập nhật địa chỉ thành công'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Address',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            backgroundColor: Colors.white,
            content: Text(
              //'Are you sure you want to delete this address?',
              'Bạn có chắc chắn muốn xóa địa chỉ này không?',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.primaryDark),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AddressBloc>().add(
                    DeleteAddress(addressId: index),
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  //'Delete',
                  'Xóa',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustomWidget(
        //title: 'Shipping Address'
        title: 'Địa chỉ giao hàng',
      ),
      body: Container(
        color: AppColors.background,
        child: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is AddressLoaded) {
              final addresses = state.addresses;
              if (addresses.isEmpty) {
                return Center(
                  child: Text(
                    //'Your address list is empty.'
                    'Danh sách địa chỉ của bạn đang trống.',
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          SizedBox(height: 10.0),
                          AddressCardWidget(
                            title: addresses[index].tagName,
                            name: addresses[index].recipientName,
                            phone: addresses[index].phoneNumber,
                            address: addresses[index].address,
                            isDefault:
                                addresses[index].isDefault == 1 ? true : false,
                            onEdit:
                                () => _showEditDialog(
                                  addresses[index].id,
                                  addresses[index].tagName,
                                  addresses[index].recipientName,
                                  addresses[index].phoneNumber,
                                  addresses[index].address,
                                  addresses[index].isDefault == 1,
                                  addresses[index].tagId,
                                ),
                            onDelete:
                                () => _showDeleteDialog(addresses[index].id),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
            } else if (state is AddressError) {
              return Center(child: Text(state.message));
            } else {
              return Center(
                child: Text(
                  //'Press the button to load addresses.'
                  'Nhấn nút để tải địa chỉ.',
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 360,
            margin: EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-address');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: AppColors.primaryDark,
              ),
              child: Text(
                //'Add Address',
                'Thêm địa chỉ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
