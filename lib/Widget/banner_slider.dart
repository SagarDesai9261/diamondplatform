import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../model/service.dart';

class BannerSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerDataProvider>(context);
    final banners = bannerProvider.banners;
    final currentSlideProvider = Provider.of<CurrentSlideProvider>(context);

    return Column(
      children: [
        CarouselSlider(

          items: banners.map((banner) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top:3),
              /*decoration: BoxDecoration(
               // borderRadius: BorderRadius.circular(20)
              ),*/
              child: Builder(
                builder: (BuildContext context) {
                  return  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(banner.imageUrl,fit: BoxFit.fill,),
                  );
                },
              ),
            );
          }).toList(),
          options: CarouselOptions(
           autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 3,
            onPageChanged: (index, reason) {
              currentSlideProvider.updateCurrentSlide(index);
            },
            // Customize your slider options here
          ),
        ),
        //SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: banners.map((banner) {
            int index = banners.indexOf(banner);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentSlideProvider.currentSlide
                    ? Colors.blue
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
