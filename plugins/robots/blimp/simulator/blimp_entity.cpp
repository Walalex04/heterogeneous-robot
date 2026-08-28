/**
 *  @file <argos3/plugins/robots/blimp/simulator/blimp_entity.cpp>
 * 
 *  @author Walter A. Gonzabay 
 * 
 *  
 */


#include "blimp_entity.h"

#include <argos3/core/simulator/space/space.h>
#include <argos3/core/simulator/entity/controllable_entity.h>
#include <argos3/core/simulator/entity/embodied_entity.h>
#include <argos3/plugins/simulator/entities/led_equipped_entity.h>
#include <argos3/plugins/simulator/entities/quadrotor_entity.h>
#include <argos3/plugins/simulator/entities/rab_equipped_entity.h>



namespace argos {



    static const Real HEIGHT            = 0.010f;
    static const Real BODY_HEIGHT       = 0.008f;
    static const Real BODY_ELEVATION    = HEIGHT + BODY_HEIGHT;
    static const Real RAB_ELEVATION     = BODY_ELEVATION;
    static const Real LED_CPU_ELEVATION = 0.0f;

    CBlimpEntity():CComposableEntity(nullptr),
      m_pcControllableEntity(nullptr),
      m_pcEmbodiedEntity(nullptr),
      m_pcQuadRotorEntity(nullptr),
      m_pcLEDEquippedEntity(nullptr),
      m_pcRABEquippedEntity(nullptr){

      }


    CBlimpEntity::CBlimpEntity(const std::string& str_id,
                            const std::string& str_controller_id,
                            const CVector3& c_position,
                            const CQuaternion& c_orientation,
                            Real f_rab_range,
                            size_t un_rab_data_size,
                            const CRadians& c_perspcam_aperture,
                            Real f_perspcam_focal_length,
                            Real f_perspcam_range) :
      CComposableEntity(nullptr),
      m_pcControllableEntity(nullptr),
      m_pcEmbodiedEntity(nullptr),
      m_pcQuadRotorEntity(nullptr),
      m_pcLEDEquippedEntity(nullptr),
      m_pcRABEquippedEntity(nullptr){

        try
        {

            m_pcEmbodiedEntity = new CEmbodiedEntity(this, "body_0", c_position, c_orientation);
            AddComponent(*m_pcEmbodiedEntity);

            /* Quadrotor entity */
            m_pcQuadRotorEntity = new CQuadRotorEntity(this, "quadrotor_0");
            AddComponent(*m_pcQuadRotorEntity);
            /* LED equipped entity  */
            m_pcLEDEquippedEntity = new CLEDEquippedEntity(this, "leds_0");
            m_pcLEDEquippedEntity->AddLED(
                CVector3(0.0f, 0.0f, LED_CPU_ELEVATION),
                m_pcEmbodiedEntity->GetOriginAnchor());
            AddComponent(*m_pcLEDEquippedEntity);


            m_pcRABEquippedEntity = new CRABEquippedEntity(
                this,
                "rab_0",
                un_rab_data_size,
                f_rab_range,
                cRABAnchor,
                *m_pcEmbodiedEntity);

            AddComponent(*m_pcRABEquippedEntity);

            m_pcEmbodiedEntity->EnableAnchor("rab");

            m_pcControllableEntity = new CControllableEntity(this, "controller_0");
            AddComponent(*m_pcControllableEntity);
            m_pcControllableEntity->SetController(str_controller_id);
            /* Update components */
            UpdateComponents();
        }
        catch(CARGoSException& ex)
        {
            THROW_ARGOSEXCEPTION_NESTED("Failed to initialize entity \"" << GetId() << "\".", ex);
        }
        

      }
    
}