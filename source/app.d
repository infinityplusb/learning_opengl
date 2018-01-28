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

	// TODO what is this?
	// create a shader program made of a single fragment shader
    string simpleProgram =
	q{#version 330 core

		#if VERTEX_SHADER
		in vec3 position;
        layout(location = 0) in vec3 vertexPosition_modelspace;
        void main()
        {
            gl_Position = vec4(position.x, 
				position.y,
				position.z,
				1.0
			);
		}
        #endif

        #if FRAGMENT_SHADER
        out vec3 color;
		void main()
		{
			color = vec3(1.0,0.0,0.0);
		}
        #endif
    };

	writeln("Getting started");
	window.setTitle("Simple Triangle");

	auto program = scoped!GLProgram(gl, simpleProgram);

	// create an object to represent a 3D vertex
	static struct Vertex
	{
		vec3f position;
		vec2f coordinates;
	}

	// create a triangle from multiple Vertexs (vertices :P)
	Vertex[] triangle;
	triangle ~= Vertex(vec3f(-1, -1, 0), vec2f(0,0));
	triangle ~= Vertex(vec3f(+1, -1, 0), vec2f(1,0));
	triangle ~= Vertex(vec3f(0, +1, 0), vec2f(1,1));

	auto triangleVBO = scoped!GLBuffer(gl, GL_ARRAY_BUFFER, GL_STATIC_DRAW, triangle[]);

    // Create an OpenGL vertex description from the Vertex structure.
    auto triangleVS = new VertexSpecification!Vertex(program);
	
	auto vao = scoped!GLVAO(gl);

	{
		vao.bind();
		triangleVBO.bind();
		triangleVS.use();
		vao.unbind();
	}

	while(!sdl2.keyboard.isPressed(SDLK_ESCAPE))
    {
        sdl2.processEvents();

        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		program.use();
		void drawFullTriangle()
        {
            vao.bind();
            glDrawArrays(GL_TRIANGLES, 0, cast(int)(triangleVBO.size() / triangleVS.vertexSize()));
            vao.unbind();
        }
        drawFullTriangle();
		program.unuse();

        window.swapBuffers();
    }
}
