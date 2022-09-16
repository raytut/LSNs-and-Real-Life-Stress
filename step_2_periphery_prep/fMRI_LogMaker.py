"""

Script that converts Presntation logs into structured format for fMRI analysis.
Processes both fMRI event and block data into structures for fMRI and behavioural
analysis.

"""
#Import Libraries
import os
import numpy as np
import pandas as pd

#Turnoff write warning in Pandas
pd.options.mode.chained_assignment = None

#File Path Location
#sub = input ("\nParticipant number? ( e.g. 1 , 2, 3...): ")
#session = input ("\nSession? (1 or 2): ")
#sub=str(sub)
###################
#For looping (Tab below  hash line 2x))
for subj in range (1,157):
	print(str(subj))
	for sess in (1,2):
		sub=str(subj)
		session=str(sess)		
###################
		sub_nr = sub.rjust (3, '0')
		filepath = ("/project/3013068.02/data/sub_" + sub_nr + "/logs/mri/")
		if os.path.exists(str(filepath)):
			
			os.chdir (str(filepath))
			#Loop Over Run 
			for runs in range (1, 7):
					
				#Open Log for Specific Run
				file_name = (str("Sub" + sub + "_mri_s" + str(session) + "_r" + str(runs) + ".txt") )  
				if os.path.exists(filepath+file_name) == True:
					file = str("Sub" + sub + "_mri_s" + str(session) + "_r" + str(runs) + ".txt")  
					data = pd.read_csv(file, header = 0, delimiter="\t", index_col = None, )
					data.columns = data.columns.str.replace(' ', '')
					data = data.drop (['Trial_Type'], axis = 1)
				
					#Get data for each trial type
					nback = data.drop ([1, 3], axis = 0)
					nback.name = "nback"
					oddball = data.drop ([2,3], axis = 0)
					oddball.name = "oddball"
					memory = data.drop ([1,2], axis = 0)
					memory.name = "memory"
					
					#Put data frames in array
					data= [nback, oddball, memory]
					
					#Loop over data frames in each trial type
					for i, log in enumerate(data):
						# nBack trials
						if i==0:
							# Make the Block log
							#Select relevant coloumns from log
							log = data[i]
							log = log.iloc [:,[8,6]]
							log = log.drop_duplicates()
							#Add coloumns, and reformat timing
							log.insert (2, "Duration", 27)
							log.insert (3, "Weight", 1)
							log.insert (0, "Onset", ((log["Correct_Resp"] - log["Block_Off"])/1000))
							log = log.drop (['Block_Off', 'Correct_Resp'], axis = 1)
							log.to_csv ('nback_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
							# Make the Event Log
							## Select coloumns we need
							log_event=data[i]
							log_event=log_event.iloc[:,[1,2,3,5,8]]
							## Calculate the proper onsets and offsets
							log_event.insert(0,"Onset", ((log_event["Stim_Valence"]-log_event["Block_Off"])/1000))
							log_event.insert(1,"Offset", (((log_event["Trial_On"]-log_event["Block_Off"])/1000))-log_event["Onset"])
							## Only keep the nbacks, and filter to dataframe we need
							event_instances=log_event["Button_Press"]==1
							log_event=log_event[event_instances]
							log_event=log_event.iloc[:,[0,1,4]]
							# Writeout event log
							log_event.to_csv ('nback_event_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
						# Oddball Trials
						elif i==1:
							# Oddball as Block
							log = data[i]
							log = log.iloc [:,[8,6]]
							log = log.drop_duplicates()
							#Add coloumns, and reformat timing
							log.insert (2, "Duration", 27)
							log.insert (3, "Weight", 1)
							log.insert (0, "Onset", ((log["Correct_Resp"] - log["Block_Off"])/1000))
							log = log.drop (['Block_Off', 'Correct_Resp'], axis = 1)
							log.to_csv ('oddball_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
							# Event Log for Oddball
							## Subset the data we need
							type_of_data = "oddball"
							event_odd=data[i]
							event_odd = event_odd[event_odd['Stim_Shown']==0]
							## Rename coloumns 
							event_odd=event_odd.rename(index=str, columns={'Stim_Valence':'Onsets','Trial_Off':'RT', 'Block_Off':'Experiment_Onset' })	  
							# Make the needed coloumns for FSL (adjusting for experiment start)
							event_odd['Onsets']=((event_odd['Onsets']-event_odd['Experiment_Onset'])/1000)
							event_odd.insert (0, "Onset", event_odd.Onsets)
							event_odd.insert (1, "Duration", 0.8)
							event_odd.insert (2, "Weight", 1)
							event_odd.Weight=event_odd.Weight/1000
							event_odd = event_odd.iloc [:,[0,1,2]]
							# Save to CSV
							event_odd.to_csv ('oddball_event_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
							# Add non-oddball trial list (same as above, but with different trials):
							event_nonodd=data[i]
							event_nonodd = event_nonodd[event_nonodd['Stim_Shown']==1]
							event_nonodd=event_nonodd.rename(index=str, columns={'Stim_Valence':'Onsets', 
												                           'Trial_Off':'RT', 'Block_Off':'Experiment_Onset' })
							event_nonodd['Onsets']=((event_nonodd['Onsets']-event_nonodd['Experiment_Onset'])/1000)
							event_nonodd.insert (0, "Onset", event_nonodd.Onsets)
							event_nonodd.insert (1, "Duration", 0.1)
							event_nonodd.insert (2, "Weight", 1)
							event_nonodd = event_nonodd.iloc [:,[0,1,2]]
							event_nonodd.to_csv('notball_event_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
						##Memeory Trials    
						elif i == 2:
							
							# Memory as Block
							log = data[i]
							log = log.iloc [:,[8,6]]
							log = log.drop_duplicates()
							#Add coloumns, and reformat timing
							log.insert (2, "Duration", 27)
							log.insert (3, "Weight", 1)
							log.insert (0, "Onset", ((log["Correct_Resp"] - log["Block_Off"])/1000))
							log = log.drop (['Block_Off', 'Correct_Resp'], axis = 1)
							log.to_csv ('memory_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
							# Memory event
							## Subset and rename the coloumns
							event_mem = data[i]
							event_mem = event_mem.drop_duplicates()
							event_mem = event_mem.rename(index=str, columns={"Stim_Shown":"Stim_Valence_corr", "ReactionTime":"Button_Pressed", "Button_Press":"Correct_Response", "Trial_On":"Trial_Off",
												                             "Trial_Off":"RT",
												                             "Block_Off":"Experiment_Onset"})
							   
							## Now we make one event related file.
							### Make a copy
							event_mem_all=event_mem.copy()
							### Set 3-coloumns for FSL
							event_mem_all.insert(0, "Onset", ((event_mem_all["Stim_Valence"] - event_mem_all["Experiment_Onset"])/1000))
							event_mem_all.insert(1, "Offset",(((event_mem_all["Trial_Off"] - event_mem_all["Experiment_Onset"])/1000))-event_mem_all["Onset"])
							event_mem_all.insert(2, "Weight", 1)
							### Subset the ones we need
							event_mem_all=event_mem_all.iloc[:,[0,1,2]]
							### Save as csv
							event_mem_all.to_csv ('memory_event_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )
							
							## Now make events for correct/incorrect responses
							### This sets the 2 conditions for calculating correct and wrong trials 
							conditions = [
									(event_mem['Button_Pressed']) == (event_mem['Correct_Response']),
									(event_mem['Button_Pressed']) != (event_mem['Correct_Response'])]
							choices = [1, 2]
							### Makes a coloumn with 4 possible conditions for Correct and Wrong
							event_mem['MEM_CORR'] = np.select(conditions, choices, default=0)
							
							### DF for Correct responses:
							df_corr=event_mem[event_mem.MEM_CORR==1]
							df_miss=event_mem[event_mem.MEM_CORR==2]
							memory_types=[df_corr, df_miss]
							
							# For the MRI Logs
							for q, memory_type in enumerate(memory_types):
								memory_type.rename(columns={'Stim_Valence':'Onsets'}, inplace=True)
								#memory_type['Duration']= memory_type['Trial_On ']-memory_type['Onset']
								memory_type.Onsets=((memory_type.Onsets-memory_type.Experiment_Onset)/1000)
								memory_type = memory_type.iloc [:,[1,3]]
								memory_type.RT=memory_type.RT/1000
								memory_type = memory_type.drop_duplicates()
								memory_type.insert (1, "Duration", 0)
								if q==0:
									mem_file_name="memory_corr"
								else:
									mem_file_name="memory_inco"
								memory_type.to_csv (mem_file_name+'_s' + str(session) + '_r' + str(runs) + '.txt', sep = '\t', header=False, index=False )

						#Increase Counter
						i = i + 1
				else:
					print (str(file_name) + " does not exist...")
