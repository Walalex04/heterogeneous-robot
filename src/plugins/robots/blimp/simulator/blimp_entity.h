/**
 *  @file <argos3/plugins/robots/blimp/simulator/blimp_entity.cpp>
 * 
 *  @author Walter A. Gonzabay 
 * 
 *  
 */

#ifndef BLIMP_ENTITY_H
#define BLIMP_ENTITY_H

namespace{
    class CControllableEntity;
    class CEmbodiedEntity;
    class CBlimpEntity;
    class CQuadRotorEntity;
    class CLEDEquippedEntity;
    class CRABEquippedEntity;
}


#include <argos3/core/simulator/entity/composable_entity.h>
#include <argos3/plugins/simulator/entities/quadrotor_entity.h>
#include <argos3/plugins/simulator/entities/led_equipped_entity.h>
#include <argos3/plugins/simulator/entities/rab_equipped_entity.h>

namespace argos {
    class CBlimpEntity : public CComposableEntity{
        public:

            
            CBlimpEntity();

            CBlimpEntity(
                const std::string& str_id,
                const std::string& str_controller_id,
                const CVector3& c_poisition = CVector3(),
                const CQuaternion& c_orientation = CQuaternion(),
                Real f_rab_range = 3.0f,
                size_t un_ran_data_size = 10,
                const CRadians& c_perspcam_aperture = ToRadians(CDegrees(33.75f)),
                Real f_perspcam_focal_length = 0.035f,
                Real f_perspcam_range = 3.0f);

            virtual void Init(TConfigurationNode& t_tree);
            virtual void Reset();
            virtual void UpdateComponents();



            inline CControllableEntity& GetControllableEntity(){
                return *m_pcControllableEntity;
            }

            inline CEmbodiedEntity& GetEmbodiedEntity(){
                return *m_pcEmbodiedEntity;
            }

            inline CQuadRotorEntity& GetQuadRotorEntity(){
                return *m_pcQuadRotorEntity;
            }

             inline CRABEquippedEntity& GetRABEquippedEntity() {
                return *m_pcRABEquippedEntity;
            }

            inline CLEDEquippedEntity& GetLEDEquippedEntity() {
                return *m_pcLEDEquippedEntity;
            }


        private:
            CControllableEntity*    m_pcControllableEntity;
            CEmbodiedEntity*        m_pcEmbodiedEntity;
            CQuadRotorEntity*       m_pcQuadRotorEntity;
            CLEDEquippedEntity*     m_pcLEDEquippedEntity;
            CRABEquippedEntity*     m_pcRABEquippedEntity;

    };
}




#endif