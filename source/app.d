import std.math,
       std.random,
       std.typecons;

import std.stdio;

import derelict.util.loader;

import gfm.logger,
       gfm.sdl2,
       gfm.opengl,
       gfm.math;

void main()
{
	int width = 1280;
	int height = 720;
	double ratio = width / cast(double)height;

	// create a coloured console logger
    auto log = new ConsoleLogger();

    // load dynamic libraries
    auto sdl2 = scoped!SDL2(log, SharedLibVersion(2, 0, 0));
    auto gl = scoped!OpenGL(log);

    // You have to initialize each SDL subsystem you want by hand
    sdl2.subSystemInit(SDL_INIT_VIDEO);
    sdl2.subSystemInit(SDL_INIT_EVENTS);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // create an OpenGL-enabled SDL window
    auto window = scoped!SDL2Window(sdl2,
                                    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                    width, height,
                                    SDL_WINDOW_OPENGL);

    gl.reload();

    // redirect OpenGL output to our Logger
    gl.redirectDebugOutput();

	writeln("Getting started");
	window.setTitle("Simple Window");

	
	while(!sdl2.keyboard.isPressed(SDLK_ESCAPE))
    {
        sdl2.processEvents();

        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        window.swapBuffers();
    }
}
