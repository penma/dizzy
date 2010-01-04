#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <X11/Xlib.h>
#include <GL/glx.h>

static Display *dpy;
static Window win;
static XVisualInfo *vi;
static GLXContext cx;

MODULE = Dizzy::GLX	PACKAGE = Dizzy::GLX

PROTOTYPES: DISABLE

int
GLX_Setup(wid)
	int wid
	CODE:
		win = wid;
		dpy = XOpenDisplay(0);
		if (!dpy) {
			XSRETURN_NO;
		}
		vi = glXChooseVisual(dpy, DefaultScreen(dpy), (int[]){ GLX_RGBA, GLX_DOUBLEBUFFER, None });
		cx = glXCreateContext(dpy, vi, 0, GL_TRUE);

		glXMakeCurrent(dpy, win, cx);

		XSRETURN_YES;

void
GLX_SwapBuffers()
	CODE:
		glXSwapBuffers(dpy, win);

void
GLX_XEvents()
	CODE:
		XWindowAttributes xwa;
		XGetWindowAttributes(dpy, win, &xwa);
		glXMakeCurrent(dpy, win, cx);
		glViewport(0, 0, xwa.width, xwa.height);


