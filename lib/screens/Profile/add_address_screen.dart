import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_bloc.dart';
import 'package:heaven_book_app/bloc/address/address_event.dart';
import 'package:heaven_book_app/bloc/address/address_state.dart';
import 'package:heaven_book_app/model/tag_address.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:heaven_book_app/widgets/appbar_custom_widget.dart';
import 'package:heaven_book_app/widgets/textfield_custom_widget.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  TagAddress? selectedTag;
  final ValueNotifier<bool> defaultSwitch = ValueNotifier<bool>(false);

  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController subAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAddressData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    subAddressController.dispose();
    defaultSwitch.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    if (nameController.text.trim().isEmpty) {
      //_showErrorSnackBar('Please enter recipient name');
      _showErrorSnackBar('Vui lòng nhập tên người nhận');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      //_showErrorSnackBar('Please enter phone number');
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
      return;
    }

    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phoneController.text.trim())) {
      //_showErrorSnackBar('Please enter a valid phone number (10-11 digits)');
      _showErrorSnackBar('Vui lòng nhập số điện thoại hợp lệ (10-11 chữ số)');
      return;
    }

    if (selectedProvince == null) {
      //_showErrorSnackBar('Please select Province/City');
      _showErrorSnackBar('Vui lòng chọn Tỉnh/Thành phố');
      return;
    }

    if (selectedDistrict == null) {
      //_showErrorSnackBar('Please select District');
      _showErrorSnackBar('Vui lòng chọn Quận/Huyện');
      return;
    }

    if (selectedWard == null) {
      //_showErrorSnackBar('Please select Ward/Commune');
      _showErrorSnackBar('Vui lòng chọn Phường/Xã');
      return;
    }

    if (selectedTag == null) {
      //_showErrorSnackBar('Please select an address tag');
      _showErrorSnackBar('Vui lòng chọn thẻ địa chỉ');
      return;
    }

    _submitAddress();
  }

  void _submitAddress() {
    final String fullAddress;

    if (subAddressController.text.isEmpty) {
      fullAddress = '$selectedWard, $selectedDistrict, $selectedProvince';
    } else {
      fullAddress =
          '${subAddressController.text.trim()} - $selectedWard, $selectedDistrict, $selectedProvince';
    }

    context.read<AddressBloc>().add(
      AddAddress(
        recipientName: nameController.text.trim(),
        address: fullAddress,
        phoneNumber: phoneController.text.trim(),
        tagId: selectedTag!.id,
        isDefault: defaultSwitch.value,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  Future<void> loadAddressData() async {
    final String response = await rootBundle.loadString(
      'assets/data/vietnamAddress.json',
    );
    final data = await json.decode(response);
    setState(() {
      provinces = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      //'Address added successfully!',
                      'Thêm địa chỉ thành công!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 3),
              elevation: 8,
            ),
          );

          final navigator = Navigator.of(context);
          Future.delayed(Duration(milliseconds: 1500), () {
            if (mounted && navigator.canPop()) {
              navigator.pop(true);
            }
          });
        } else if (state is AddressError) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppbarCustomWidget(
          title:
              //'New Address'
              'Địa chỉ mới',
        ),
        body: Container(
          color: AppColors.background,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
              padding: EdgeInsets.only(top: 32.0, left: 24.0, right: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12.0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextfieldCustomWidget(
                      //label: 'Name',
                      label: 'Tên',
                      controller: nameController,
                    ),
                    SizedBox(height: 6.0),

                    TextfieldCustomWidget(
                      //label: 'Phone',
                      label: 'Số điện thoại',
                      controller: phoneController,
                    ),
                    SizedBox(height: 6.0),

                    LocationPickerField(
                      //label: 'Location Information',
                      label: 'Thông tin địa chỉ',
                      controller: addressController,
                      value:
                          selectedProvince != null &&
                                  selectedDistrict != null &&
                                  selectedWard != null
                              ? '$selectedWard, $selectedDistrict, $selectedProvince'
                              : null,
                      onTap: () async {
                        String? province = selectedProvince;
                        String? district = selectedDistrict;
                        String? ward = selectedWard;
                        await showDialog(
                          context: context,
                          builder: (context) {
                            List<dynamic> tempDistricts =
                                province != null
                                    ? provinces.firstWhere(
                                      (p) => p['Name'] == province,
                                    )['Districts']
                                    : [];
                            List<dynamic> tempWards =
                                district != null
                                    ? tempDistricts.firstWhere(
                                      (d) => d['Name'] == district,
                                    )['Wards']
                                    : [];
                            String? tempProvince = province;
                            String? tempDistrict = district;
                            String? tempWard = ward;
                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return AlertDialog(
                                  title: Text(
                                    //'Select Location'
                                    'Chọn địa điểm',
                                  ),
                                  backgroundColor: Colors.white,
                                  shadowColor: Colors.black26,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          //labelText: 'Province/City',
                                          labelText: 'Tỉnh/Thành phố',
                                        ),
                                        value: tempProvince,
                                        items:
                                            provinces.map<
                                              DropdownMenuItem<String>
                                            >((province) {
                                              return DropdownMenuItem<String>(
                                                value: province['Name'],
                                                child: Text(province['Name']),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            tempProvince = value;
                                            tempDistrict = null;
                                            tempWard = null;
                                            tempDistricts =
                                                provinces.firstWhere(
                                                  (p) => p['Name'] == value,
                                                )['Districts'];
                                            tempWards = [];
                                          });
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                      DropdownButtonFormField<String>(
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          //labelText: 'District',
                                          labelText: 'Quận/Huyện',
                                        ),
                                        value: tempDistrict,
                                        items:
                                            tempDistricts.map<
                                              DropdownMenuItem<String>
                                            >((district) {
                                              return DropdownMenuItem<String>(
                                                value: district['Name'],
                                                child: Text(district['Name']),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            tempDistrict = value;
                                            tempWard = null;
                                            tempWards =
                                                tempDistricts.firstWhere(
                                                  (d) => d['Name'] == value,
                                                )['Wards'];
                                          });
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                      DropdownButtonFormField<String>(
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          //labelText: 'Ward/Commune',
                                          labelText: 'Phường/Xã',
                                        ),
                                        value: tempWard,
                                        items:
                                            tempWards.map<
                                              DropdownMenuItem<String>
                                            >((ward) {
                                              return DropdownMenuItem<String>(
                                                value: ward['Name'],
                                                child: Text(ward['Name']),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            tempWard = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        //'Cancel',
                                        'Hủy',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryDark,
                                      ),
                                      onPressed:
                                          tempProvince != null &&
                                                  tempDistrict != null &&
                                                  tempWard != null
                                              ? () {
                                                setState(() {
                                                  selectedProvince =
                                                      tempProvince;
                                                  selectedDistrict =
                                                      tempDistrict;
                                                  selectedWard = tempWard;
                                                  districts =
                                                      provinces.firstWhere(
                                                        (p) =>
                                                            p['Name'] ==
                                                            tempProvince,
                                                      )['Districts'];
                                                  wards =
                                                      districts.firstWhere(
                                                        (d) =>
                                                            d['Name'] ==
                                                            tempDistrict,
                                                      )['Wards'];

                                                  // Update controller với selected location
                                                  addressController.text =
                                                      '$selectedWard, $selectedDistrict, $selectedProvince';
                                                });
                                                Navigator.of(context).pop();
                                              }
                                              : null,
                                      child: Text(
                                        //'Done',
                                        'Xong',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 6.0),

                    TextfieldCustomWidget(
                      //label: 'Address Description',
                      label: 'Mô tả địa chỉ',
                      controller: subAddressController,
                    ),
                    SizedBox(height: 6.0),

                    BlocBuilder<AddressBloc, AddressState>(
                      builder: (context, state) {
                        if (state is AddressLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is AddressError) {
                          return Center(
                            child: Text(
                              //'Failed to load addresses'
                              'Tải địa chỉ thất bại',
                            ),
                          );
                        } else if (state is AddressLoaded) {
                          return AddressTagWidget(
                            tags: state.tagAddress,
                            selectedTag: selectedTag,
                            onTagSelected: (tag) {
                              setState(() {
                                selectedTag = tag;
                              });
                            },
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),

                    SizedBox(height: 6.0),

                    ValueListenableBuilder<bool>(
                      valueListenable: defaultSwitch,
                      builder: (context, value, child) {
                        return Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              //'Set as Default',
                              'Đặt làm mặc định',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Switch(
                              value: value,
                              onChanged: (bool newValue) {
                                defaultSwitch.value = newValue;
                              },
                              inactiveThumbColor: Colors.black45,
                              activeColor: AppColors.primaryDark,
                            ),
                            onTap: () {
                              defaultSwitch.value = !defaultSwitch.value;
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 340,
              margin: EdgeInsets.only(bottom: 30.0),
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
                onPressed: _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryDark,
                ),
                child: Text(
                  //'Done',
                  'Xong',
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
      ),
    );
  }
}

class AddressTagWidget extends StatelessWidget {
  final List<TagAddress> tags;
  final TagAddress? selectedTag;
  final Function(TagAddress) onTagSelected;

  const AddressTagWidget({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          //'Address Tags',
          'Thẻ địa chỉ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children:
              tags.map((tag) {
                return ChoiceChip(
                  label: Text(
                    tag.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  selected: selectedTag?.id == tag.id,
                  onSelected: (selected) {
                    if (selected) {
                      onTagSelected(tag);
                    }
                  },
                  selectedColor: Colors.blue[100],
                  backgroundColor: Colors.grey[200],
                  checkmarkColor: AppColors.primaryDark,
                  labelStyle: TextStyle(
                    color:
                        selectedTag == tag
                            ? AppColors.primaryDark
                            : Colors.black,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class LocationPickerField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  final String label;
  final TextEditingController controller;
  const LocationPickerField({
    super.key,
    required this.value,
    required this.onTap,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextfieldCustomWidget(
          label: label,
          controller: controller,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
