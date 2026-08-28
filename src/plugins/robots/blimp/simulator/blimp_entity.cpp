/**
 * @file <argos3/plugins/robots/blimp/simulator/blimp_entity.cpp>
 *
 * @author Walter A. Gonzabay
 */

#include "blimp_entity.h"

#include <argos3/core/simulator/space/space.h>
#include <argos3/core/simulator/entity/controllable_entity.h>
#include <argos3/core/simulator/entity/embodied_entity.h>
#include <argos3/plugins/simulator/entities/led_equipped_entity.h>
#include <argos3/plugins/simulator/entities/quadrotor_entity.h>
#include <argos3/plugins/simulator/entities/rab_equipped_entity.h>

namespace argos {

   /****************************************/
   /****************************************/

   static const Real HEIGHT            = 0.010f;
   static const Real BODY_HEIGHT       = 0.008f;
   static const Real BODY_ELEVATION    = HEIGHT + BODY_HEIGHT;
   static const Real RAB_ELEVATION     = BODY_ELEVATION;
   static const Real LED_CPU_ELEVATION = 0.0f;

   /****************************************/
   /****************************************/

   CBlimpEntity::CBlimpEntity() :
      CComposableEntity(nullptr),
      m_pcControllableEntity(nullptr),
      m_pcEmbodiedEntity(nullptr),
      m_pcQuadRotorEntity(nullptr),
      m_pcLEDEquippedEntity(nullptr),
      m_pcRABEquippedEntity(nullptr) {
   }

   /****************************************/
   /****************************************/

   CBlimpEntity::CBlimpEntity(const std::string& str_id,
                              const std::string& str_controller_id,
                              const CVector3& c_position,
                              const CQuaternion& c_orientation,
                              Real f_rab_range,
                              size_t un_rab_data_size,
                              const CRadians& c_perspcam_aperture,
                              Real f_perspcam_focal_length,
                              Real f_perspcam_range) :
      CComposableEntity(nullptr, str_id),
      m_pcControllableEntity(nullptr),
      m_pcEmbodiedEntity(nullptr),
      m_pcQuadRotorEntity(nullptr),
      m_pcLEDEquippedEntity(nullptr),
      m_pcRABEquippedEntity(nullptr) {
      try {
         /*
          * Create and init components
          */
         /* Embodied entity */
         m_pcEmbodiedEntity = new CEmbodiedEntity(this, "body_0", c_position, c_orientation);
         AddComponent(*m_pcEmbodiedEntity);

         /* Quadrotor entity */
         m_pcQuadRotorEntity = new CQuadRotorEntity(this, "quadrotor_0");
         AddComponent(*m_pcQuadRotorEntity);

         /* LED equipped entity */
         m_pcLEDEquippedEntity = new CLEDEquippedEntity(this, "leds_0");
         m_pcLEDEquippedEntity->AddLED(
            CVector3(0.0f, 0.0f, LED_CPU_ELEVATION),
            m_pcEmbodiedEntity->GetOriginAnchor());
         AddComponent(*m_pcLEDEquippedEntity);

         /* RAB equipped entity */
         SAnchor& cRABAnchor = m_pcEmbodiedEntity->AddAnchor(
            "rab",
            CVector3(0.0f, 0.0f, RAB_ELEVATION));
         m_pcRABEquippedEntity = new CRABEquippedEntity(
            this,
            "rab_0",
            un_rab_data_size,
            f_rab_range,
            cRABAnchor,
            *m_pcEmbodiedEntity);
         AddComponent(*m_pcRABEquippedEntity);
         m_pcEmbodiedEntity->EnableAnchor("rab");

         /* Controllable entity */
         m_pcControllableEntity = new CControllableEntity(this, "controller_0");
         AddComponent(*m_pcControllableEntity);
         m_pcControllableEntity->SetController(str_controller_id);

         /* Update components */
         UpdateComponents();
      }
      catch(CARGoSException& ex) {
         THROW_ARGOSEXCEPTION_NESTED("Failed to initialize entity \"" << GetId() << "\".", ex);
      }
   }

   /****************************************/
   /****************************************/

   void CBlimpEntity::Init(TConfigurationNode& t_tree) {
      try {
         /* Init parent */
         CComposableEntity::Init(t_tree);

         /* Embodied entity */
         m_pcEmbodiedEntity = new CEmbodiedEntity(this);
         AddComponent(*m_pcEmbodiedEntity);
         m_pcEmbodiedEntity->Init(GetNode(t_tree, "body"));

         /* Quadrotor entity */
         m_pcQuadRotorEntity = new CQuadRotorEntity(this, "quadrotor_0");
         AddComponent(*m_pcQuadRotorEntity);

         /* LED equipped entity */
         m_pcLEDEquippedEntity = new CLEDEquippedEntity(this, "leds_0");
         m_pcLEDEquippedEntity->AddLED(
            CVector3(0.0f, 0.0f, LED_CPU_ELEVATION),
            m_pcEmbodiedEntity->GetOriginAnchor());
         AddComponent(*m_pcLEDEquippedEntity);

         /* RAB equipped entity */
         Real fRABRange = 3.0f;
         GetNodeAttributeOrDefault(t_tree, "rab_range", fRABRange, fRABRange);
         UInt32 unRABDataSize = 10;
         GetNodeAttributeOrDefault(t_tree, "rab_data_size", unRABDataSize, unRABDataSize);
         SAnchor& cRABAnchor = m_pcEmbodiedEntity->AddAnchor("rab", CVector3(0.0f, 0.0f, RAB_ELEVATION));
         m_pcRABEquippedEntity = new CRABEquippedEntity(
            this,
            "rab_0",
            unRABDataSize,
            fRABRange,
            cRABAnchor,
            *m_pcEmbodiedEntity);
         AddComponent(*m_pcRABEquippedEntity);
         m_pcEmbodiedEntity->EnableAnchor("rab");

         /* Controllable entity */
         m_pcControllableEntity = new CControllableEntity(this);
         AddComponent(*m_pcControllableEntity);
         m_pcControllableEntity->Init(GetNode(t_tree, "controller"));

         /* Update components */
         UpdateComponents();
      }
      catch(CARGoSException& ex) {
         THROW_ARGOSEXCEPTION_NESTED("Failed to initialize entity \"" << GetId() << "\".", ex);
      }
   }

   /****************************************/
   /****************************************/

   void CBlimpEntity::Reset() {
      /* Reset all components */
      CComposableEntity::Reset();
      /* Update components */
      UpdateComponents();
   }

   /****************************************/
   /****************************************/

#define UPDATE(COMPONENT) if(COMPONENT && COMPONENT->IsEnabled()) COMPONENT->Update();

   void CBlimpEntity::UpdateComponents() {
      UPDATE(m_pcRABEquippedEntity);
      UPDATE(m_pcLEDEquippedEntity);
   }

   /****************************************/
   /****************************************/

   REGISTER_ENTITY(CBlimpEntity,
                   "blimp",
                   "Walter A. Gonzabay",
                   "1.0",
                   "The blimp robot model for ARGoS3.",
                   "REQUIRED XML CONFIGURATION\n\n"
                   "  <arena ...>\n"
                   "    ...\n"
                   "    <blimp id=\"blimp0\">\n"
                   "      <body position=\"0.4,2.3,0.25\" orientation=\"45,0,0\" />\n"
                   "      <controller config=\"mycntrl\" />\n"
                   "    </blimp>\n"
                   "    ...\n"
                   "  </arena>\n\n"
                   "The 'id' attribute is necessary and must be unique among the entities.\n",
                   "Usable"
      );

   /****************************************/
   /****************************************/

   REGISTER_STANDARD_SPACE_OPERATIONS_ON_COMPOSABLE(CBlimpEntity);

   /****************************************/
   /****************************************/

} // namespace argos