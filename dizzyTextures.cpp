#include "dizzyTextures.hpp"

#include <cmath>

using namespace std;

void dizzyTextures::setTexture(unsigned int tID)
{
  if(textures.size() > 0)
    if(texturesAreGenerated)
      glBindTexture(GL_TEXTURE_2D, textures[tID]);
}

dizzyTextures::dizzyTextures()
{
  res = 64; // set default resolution
  texturesAreGenerated = false;
}

void dizzyTextures::setResolution(unsigned int resolution)
{
  res = resolution;
}

unsigned int dizzyTextures::getCount()
{
  return textures.size();
}

void dizzyTextures::generateTextures() 
{
  unsigned char *texture;
  texture = new unsigned char[res*res*3];
  unsigned int texel;
  GLuint *texid;

  float dx, dy, dist, angle;
  for(int textype = 0; textype <= 5; textype++)
  {
  	texid = new GLuint;
  	for(int x = 0; x < res; x++)
  	{
  	  for(int y = 0; y < res; y++)
  	  {
  	  	dx = res/2.0f - x;
  	  	dy = res/2.0f - y;
  	  	dist = sqrt(dx*dx + dy*dy)+0.001;
  	  	angle = asin(dy / dist);
  	  	switch(textype)
  	  	{
  	  	  case 0:
  	  	    texel = (unsigned char)(sin(res / dist * M_PI / 2.0f) * 128 + 128);
            break;
          case 1:
            texel = (unsigned char)(cos(dist / res * M_PI) * 128 + 128);
            break;
          case 2:
            texel = (unsigned char)(cos(dist / res * M_PI + sin(angle)) * 128 + 128);
            break;
          case 3:
            texel = (unsigned char)(cos(dist / res * M_PI + sin(angle * 8)*0.2f) * 128 + 128);
            break;
          case 4:
            texel = (unsigned char)(cos(dist / res * M_PI + sin(angle * 2)*0.2f) * 128 + 128);
            break;
  	  	  case 5:
  	  	    texel = (unsigned char)(sin(dist / res * M_PI / 2.0f) * 128 + 128);
            break;
  	  	}
        texture[(x * res + y) * 3] = texel;
  	    texture[(x * res + y) * 3+1] = texel;
        texture[(x * res + y) * 3+2] = texel;
  	  }
  	}
  	// Generate the Texture
  	
    glGenTextures(1, texid);
    glBindTexture(GL_TEXTURE_2D, *texid);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);	// Linear Filtering
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);	// Linear Filtering
    glTexImage2D(GL_TEXTURE_2D, 0, 3, res, res, 0,
                 GL_RGB, GL_UNSIGNED_BYTE, texture);
    textures.push_back(*texid);
  }
  texturesAreGenerated = true;
}

dizzyTextures *dizzyTextures::getInstance()
{
  if(instance == NULL)
    instance = new dizzyTextures;
  return instance;
}

dizzyTextures *dizzyTextures::instance;
