#include <stdio.h>
#include <math.h>

//paramètres : quatre double correspondant à deux coordonnées (lat1,long1) et (lat2,long2)
//renvoie la distance entre les deux points correspondants
double distance(double lat1, double long1, double lat2, double long2){
  lat1*=M_PI/180;
  long1*=M_PI/180;
  lat2*=M_PI/180;
  long2*=M_PI/180;
  double a = sin((lat1-lat2)/2);
  a = a*a;
  double b = sin((long1-long2)/2);
  b = b*b*cos(lat1)*cos(lat2);
  return 2*6371 * asin(sqrt(a+b));
}

