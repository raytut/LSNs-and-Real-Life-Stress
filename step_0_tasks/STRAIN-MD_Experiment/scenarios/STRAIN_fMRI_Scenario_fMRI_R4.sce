##################################################################################
#																											#
#										Stress and Resilience Study								#
#										---------------------------								#
#																											#
#											 	fMRI  Scenario											#		
#																											#
#																											#
##################################################################################
#--------------------------------------------------------------------------------#
# Header 	  																					
#--------------------------------------------------------------------------------#

scenario= "STRAIN_fMRI_fMRI_R4.sce";
 
# Response buttons
active_buttons = 5;									
button_codes = 1, 2, 3, 4, 5;												
response_matching = simple_matching;							

# MRI settings	
scenario_type =  fMRI;			
scan_period = 2180;					
pulse_code = 10;
pulses_per_scan = 1; 

# Eye Tracker Output Port
default_output_port = 1;
pulse_width = 100;
write_codes = true;
response_port_output = false;

# Other settings
default_font_size = 18;
default_font = "Times New Roman";
default_text_color = 250,250,250;
default_background_color = 125,125,125;
screen_width = 1024;
screen_height = 768;
screen_bit_depth = 32;
antialias = 2;

#--------------------------------------------------------------------------------#
# SDL Scripts 	  																					
#--------------------------------------------------------------------------------#

begin;
	TEMPLATE "STRAIN_fMRI_Definitions.tem";	
	
#--------------------------------------------------------------------------------#
# PCL Scripts + Settings (Trial Order 4 = Practice)																			
#--------------------------------------------------------------------------------#

begin_pcl;

##Set Output for Ports
output_port oport = output_port_manager.get_port(1);

## Subject Settings
int subjnr=1;
if int(logfile.subject()) > 0  then
	subjnr = int(logfile.subject());
end;

## Run
int run=4;
## Session
include "STRAIN_fMRI_Session.pcl"

## Include Files
include "STRAIN_fMRI_Subroutine.pcl";
include "STRAIN_fMRI_Task_Oddball.pcl";		
include "STRAIN_fMRI_Task_Nback.pcl";
include "STRAIN_fMRI_Task_Retrieval.pcl";

## Start Log File
MakeOutputFile(sMRILogFileDir);


#--------------------------------------------------------------------------------#
# fMRI Tasks 	  																					
#--------------------------------------------------------------------------------#	
	
## Instruction Settings
bool odd_instruction = false;
bool nback_instruction = false;
bool ret_instruction = false;

## Present Main Instructions
fmri_instructions_1.present();
waitforbuttonpress ();
fixationcross.present();

## Wait for Pulse
int cnt_pulse = pulse_manager.main_pulse_count();
loop until 
	pulse_manager.main_pulse_count() == cnt_pulse + StartAtTrigger
begin
end;

## First MRI Pulse (start with StartAtTrigger + 1)
int starttime_mri = pulse_manager.main_pulse_time(cnt_pulse + StartAtTrigger);

## Log Start time
iExperimentOn=clock.time();

## Present Each Task With No Instruciton 
loop int order_loop; int i=64; int k; until order_loop>=(21)
		begin
		if trial_order[i]==1 then
			if odd_instruction==true then
				odd_instructions_1.present ();
				waitforbuttonpress ();
				odd_instruction=false;
			end;
			iTrial = trial_order[i];
			circle.present();
			wait (6000);
			odd_subroutine ();
			i=i+1;
			
		elseif trial_order[i]==2 then
			if nback_instruction==true then
				nback_instructions_1.present ();
				waitforbuttonpress ();
				nback_instruction=false;
			end;
			iTrial = trial_order[i];
			square.present();
			wait (6000);
			nback_subroutine (1);
			i=i+1;
			
		elseif trial_order[i]==3 then
			if ret_instruction==true then
				ret_instruction_1.present();
				waitforbuttonpress ();
				ret_instruction_2.present();
				waitforbuttonpress ();
				ret_instruction=false;
			end;
			iTrial = trial_order[i];
			triangle.present();
			wait (6000);
			ret_subroutine (1);
			i= i+1	
	end;
	order_loop= order_loop +1;
end;

## Log End time
iExperimentOff=clock.time();
WriteToOutputFile (sMRILogFileDir);

## Resting State:
fixationcross.present();
WaitForSpecButtonpress(5);
fmri_instructions_resting_state.present();
waitforbuttonpress ();
fixationcross.present();
WaitForSpecButtonpress(5);