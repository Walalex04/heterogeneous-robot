#ifndef CI_BLIMP_APRILTAG_SENSOR_H
#define CI_BLIMP_APRILTAG_SENSOR_H

namespace argos {
   class CCI_BlimpAprilTagSensor;
}

#include <argos3/core/control_interface/ci_sensor.h>
#include <argos3/core/utility/math/angles.h>
#include <argos3/core/utility/datatypes/datatypes.h>
#include <vector>

namespace argos {

   class CCI_BlimpAprilTagSensor : public CCI_Sensor {

   public:

      struct SReading {
         UInt32 Id;
         Real X;
         Real Y;
         Real Yaw;
         Real Distance;
         CRadians Angle;

         SReading();
         SReading(UInt32 un_id,
                  Real f_x,
                  Real f_y,
                  Real f_yaw,
                  Real f_distance,
                  const CRadians& c_angle);
      };

      typedef std::vector<SReading> TReadings;

   public:

      CCI_BlimpAprilTagSensor();
      virtual ~CCI_BlimpAprilTagSensor() {}

      inline const TReadings& GetReadings() const { return m_tReadings; }

#ifdef ARGOS_WITH_LUA
      virtual void CreateLuaState(lua_State* pt_lua_state);
      virtual void ReadingsToLuaState(lua_State* pt_lua_state);
#endif

   protected:

      TReadings m_tReadings;
   };
}

#endif
