##################################################################################
#--------------------------------------------------------------------------------#																											

#									Stress and Resilience Study									
#									---------------------------									

#									Oddball Recognition Scenario										


#--------------------------------------------------------------------------------#
##################################################################################

#--------------------------------------------------------------------------------#
# Header 	  																					
#--------------------------------------------------------------------------------#

scenario = "BaLS_Scenario_OddRet_R1.sce";

## Response Buttons
active_buttons = 6;							   
button_codes = 1,2,3,4,5,6;							
response_matching = simple_matching;		

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
TEMPLATE "BaLS_Definitions.tem";	

#--------------------------------------------------------------------------------#
# PCL Scripts 	  																					
#--------------------------------------------------------------------------------#

begin_pcl;

## Subject Settings
int subjnr=1;
if int(logfile.subject()) > 0  then
	subjnr = int(logfile.subject());
end;

# Session and Run
int session;
int run=1;

#Prompts for Session
string sSession;
t_Text1.set_caption("Session Number:");
t_Text1.redraw();
system_keyboard.set_case_mode(3);
sSession=system_keyboard.get_input(p_Text, t_Text2);
session = int(sSession);

## Include Files:
include "BaLS_Subroutine.pcl";
include "BaLS_Task_OddballRecall.pcl";
MakeOutputFile2 (sODDRETLogFileDir);

#--------------------------------------------------------------------------------#
# Encoding Task  																				
#--------------------------------------------------------------------------------#

oddrec_instructions.present();
WaitForAllButtonpress();

oddrec_sub();
showtext("Dit is de ende van de taak\n Bedankt!");
wait_interval (3000);
