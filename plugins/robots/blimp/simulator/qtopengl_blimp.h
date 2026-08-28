/**
 *  @file  <argos3/plugins/robots/blimp/simulator/qtopengl_blimp.h>
 * 
 *  @author Walter A. Gonzabay based on Crazyflie desing
 * 
 */


#ifndef QTOPENGL_BLIMP_H
#define QTOPENGL_BLIMP_H


#ifdef __APPLE__
#include<gl.h>
#else
#include<GL/gl.h>
#endif


namespace argos {
    class CQTOpenGLBLimp;
    class CBlimpEntity;
}


namespace argos {
    class CQTOpenGLBLimp{

        public:
            CQTOpenGLBLimp();

            virtual ~CQTOpenGLBLimp();

            virtual void Draw(CBlimpEntity& c_entity);

        protected:
    
            void DrawBody();

            void DrawRods();

            void DrawPropellers();

            void DrawCpuLED();

            /***************/
            void DrawCircle();

            void DrawAprilTagCamera();

            void SetLEDMaterial(GLfloat f_red, GLfloat f_green, GLfloat f_blue);
  
            void SetBodyMaterial();
      
            void SetRodMaterial();

            void SetPropellerMaterial();

            void SetCameraMaterial();

            void SetArrowMaterial();
        
            void MakeRod(GLfloat angle);

            void MakeRotor(GLfloat offset);

            void MakePropeller(GLfloat angle, GLfloat offset);

            
        private:
            /** Start of the display list index */
            GLuint m_unLists;

            /** Body display list */
            GLuint m_unBodyList;

            /** Rod display list */
            GLuint m_unRodList;

            /** Propeller display list */
            GLuint m_unPropellerList;

            /** Propeller cpu led list */
            GLuint m_unCpuLEDList;

            /** AprilTag camera display list */
            GLuint m_unAprilTagCameraList;

            /** Number of vertices to display the round parts */
            GLuint m_unVertices;
    };
}




#endif