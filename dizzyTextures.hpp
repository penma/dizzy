#ifndef _DIZZYTEXTURES_HPP_
#define _DIZZYTEXTURES_HPP_

#include <GL/gl.h>
#include <vector>

using std::vector;

class dizzyTextures {
  public:
    void setTexture(unsigned int texID);
    void setResolution(unsigned int resolution);
    void generateTextures();
    unsigned int getCount();
    static dizzyTextures *getInstance();
    ~dizzyTextures();
  private:
    static dizzyTextures *instance;
    unsigned int res;
    vector<GLuint> textures;
    dizzyTextures();
    bool texturesAreGenerated;
};

#endif //_DIZZYTEXTURES_HPP_
