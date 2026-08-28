/**
 * @file <argos3/plugins/robots/blimp/simulator/blimp_apriltag_default_sensor.h>
 */

#ifndef BLIMP_APRILTAG_DEFAULT_SENSOR_H
#define BLIMP_APRILTAG_DEFAULT_SENSOR_H

namespace argos {
   class CBlimpAprilTagDefaultSensor;
   class CEmbodiedEntity;
   class CControllableEntity;
   class CTagEntity;
   class CGroundAprilTagEntity;
   template<typename ENTITY> class CPositionalIndex;
}

#include <argos3/core/simulator/sensor.h>
#include <argos3/core/utility/math/vector3.h>
#include <argos3/core/utility/math/quaternion.h>
#include <argos3/core/utility/math/angles.h>
#include <argos3/plugins/robots/blimp/control_interface/ci_blimp_apriltag_sensor.h>

namespace argos {

   class CBlimpAprilTagDefaultSensor : public CSimulatedSensor,
                                           public CCI_BlimpAprilTagSensor {

   public:

      CBlimpAprilTagDefaultSensor();
      virtual ~CBlimpAprilTagDefaultSensor() {}

      virtual void SetRobot(CComposableEntity& c_entity);
      virtual void Init(TConfigurationNode& t_tree);
      virtual void Update();
      virtual void Reset();

   private:

      void AddFOVRays(const CVector3& c_camera_position,
                      const CQuaternion& c_body_orientation);
      void ProcessTag(CTagEntity& c_tag,
                      const CVector3& c_camera_position,
                      const CQuaternion& c_inv_body_orientation);
      void ProcessGroundTag(CGroundAprilTagEntity& c_tag,
                            const CVector3& c_camera_position,
                            const CQuaternion& c_inv_body_orientation);
      Real NormalizeAngle(Real f_angle) const;

   private:

      CEmbodiedEntity* m_pcEmbodiedEntity;
      CControllableEntity* m_pcControllableEntity;
      CPositionalIndex<CTagEntity>* m_pcTagIndex;
      Real m_fRange;
      CRadians m_cHalfFOV;
      CVector3 m_cCameraOffset;
      bool m_bShowRays;
      bool m_bShowFOV;
   };
}

#endif
