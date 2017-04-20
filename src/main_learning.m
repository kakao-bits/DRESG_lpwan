close all
clear
clc

load('configuration.mat')
% NEW LEARNING ---> To be placed in other file!
num_iterations = 2;
set_of_ring_hops_combinations = delta_combinations;
aggregation_on = true;
learning_approach = 0;

% Known optimal action (by main_analysis.m)
optimal_action = 1;

num_possible_actions = size(set_of_ring_hops_combinations, 1);  % Number of possible paths
    
disp('DRESG topology: ')
disp([' - Children ratio: ' num2str(child_ratio)]);
disp([' - Num. of rings: ' num2str(num_rings)]);
disp(['   � Num. of possible actions (i.e. paths) of the DRESG topology: ' num2str(num_possible_actions)]);

% Number of trials for averaging
num_trials = 1;
% Learning tunning parameters
%epsilon_initial = [0.2 0.5 1];
epsilon_initial = [0.2 1];

disp(' ')
disp('Computing learning algorithms: ')

for trial_ix = 1:num_trials
    
     disp(['- trial index ' num2str(trial_ix) '/' num2str(num_trials)]);
    
    for epsilon_ix = 1:length(epsilon_initial)

        disp([' * epsilon index ' num2str(epsilon_ix) '/' num2str(length(epsilon_initial))]);

        % Epsilon-greedy constant
        epsilon_tunning_mode = EPSILON_GREEDY_CONSTANT;
        
        [e_history, btle_history, reward_per_action, iteration_opt, iteration_all_actions_explored] = ...
            learn_optimal_routing( num_iterations, set_of_ring_hops_combinations,...
            d_ring, aggregation_on, epsilon_initial(epsilon_ix), epsilon_tunning_mode, optimal_action );
        
        energy_history_constant{trial_ix, epsilon_ix} = e_history;
        btle_history_constant(trial_ix, epsilon_ix,:,:,:) = btle_history;
        reward_per_action_constant(trial_ix, epsilon_ix,:) = reward_per_action;
        iteration_opt_constant(trial_ix, epsilon_ix) = iteration_opt;
        iteration_all_actions_explored_constant(trial_ix, epsilon_ix) = iteration_all_actions_explored;
        

        % Epsilon-greedy decreasing
        epsilon_tunning_mode = EPSILON_GREEDY_DECREASING;
        
        [e_history, btle_history, reward_per_action, iteration_opt, iteration_all_actions_explored] = ...
            learn_optimal_routing( num_iterations, set_of_ring_hops_combinations,...
            d_ring, aggregation_on, epsilon_initial(epsilon_ix), epsilon_tunning_mode, optimal_action );
        
        energy_history_decreasing{trial_ix, epsilon_ix} = e_history;
        btle_history_decreasing(trial_ix, epsilon_ix,:,:,:) = btle_history;
        reward_per_action_decreasing(trial_ix, epsilon_ix,:) = reward_per_action;
        iteration_opt_decreasing(trial_ix, epsilon_ix) = iteration_opt;
        iteration_all_actions_explored_decreasing(trial_ix, epsilon_ix) = iteration_all_actions_explored;

    end
    
end

% Get average
for epsilon_ix = 1:length(epsilon_initial)

    energy_history_constant_mean{epsilon_ix} = mean(energy_history_constant{:, epsilon_ix});
    btle_history_constant_mean(epsilon_ix, :, :, :) = mean(btle_history_constant(:,epsilon_ix,:,:,:));
    reward_per_action_constant_mean(epsilon_ix, epsilon_ix, :) = mean(reward_per_action_constant(:, epsilon_ix, :));
    iteration_opt_constant_mean(:, epsilon_ix) = mean(iteration_opt_constant(:,epsilon_ix));
    iteration_all_actions_explored_constant_mean(:, epsilon_ix) = mean(iteration_all_actions_explored_constant(:,epsilon_ix));

    energy_history_decreasing_mean{epsilon_ix} = mean(energy_history_decreasing{:, epsilon_ix});
    btle_history_decreasing_mean(epsilon_ix, :, :, :) = mean(btle_history_decreasing(:,epsilon_ix,:,:,:));
    reward_per_action_decreasing_mean(epsilon_ix, epsilon_ix, :) = mean(reward_per_action_decreasing(:, epsilon_ix, :));
    iteration_opt_decreasing_mean(:, epsilon_ix) = mean(iteration_opt_decreasing(:,epsilon_ix));
    iteration_all_actions_explored_decreasing_mean(:, epsilon_ix) = mean(iteration_all_actions_explored_decreasing(:,epsilon_ix));

end

for trial_ix = 1:num_trials
    for epsilon_ix = 1:length(epsilon_initial)
        num_unexplored_actions_constant(trial_ix, epsilon_ix) = length(find(reward_per_action_constant(trial_ix,epsilon_ix,:) == -1));
        num_unexplored_actions_decreasing(trial_ix, epsilon_ix) = length(find(reward_per_action_decreasing(trial_ix,epsilon_ix,:) == -1));
    end
end

% Display some parameters per console
disp('Results GREEDY CONSTANT:')
for epsilon_ix = 1:length(epsilon_initial)
    
    disp(['- epsilon = ' num2str(epsilon_initial(epsilon_ix))])
    
    % Statistics
    actions_selected_constant_mean = btle_history_constant_mean(epsilon_ix,:,1)';
    most_picked_action_constant_mean = mode(actions_selected_constant_mean);
    
    num_unexplored_actions_constant_mean = mean(num_unexplored_actions_constant(:,epsilon_ix));
    num_explored_actions_constant_mean = num_possible_actions - num_unexplored_actions_constant_mean;
    
    disp(['  � Num. of explored actions: ' num2str(num_explored_actions_constant_mean) '/' num2str(num_possible_actions)])
    disp(['  � Num. of unexplored actions: ' num2str(num_unexplored_actions_constant_mean) '/' num2str(num_possible_actions)])
    disp(['  � Iteration where optimal action was found: ' num2str(iteration_opt_constant_mean(epsilon_ix)) '/' num2str(num_iterations)])
    disp(['  � Iteration where all actions were tried: ' num2str(iteration_all_actions_explored_constant_mean(epsilon_ix)) '/' num2str(num_iterations)])
    
end

disp('Results GREEDY DECREASING:')
for epsilon_ix = 1:length(epsilon_initial)
    
    disp(['- epsilon = ' num2str(epsilon_initial(epsilon_ix))])
    
    % Statistics
    actions_selected_decreasing_mean = btle_history_decreasing_mean(epsilon_ix,:,1)';
    most_picked_ation_decreasing_mean = mode(actions_selected_decreasing_mean);
    
    num_unexplored_actions_decreasing_mean = mean(num_unexplored_actions_decreasing(:,epsilon_ix));
    num_explored_actions_decreasing_mean = num_possible_actions - num_unexplored_actions_decreasing_mean;
    
    disp(['  � Num. of explored actions: ' num2str(num_explored_actions_decreasing_mean) '/' num2str(num_possible_actions)])
    disp(['  � Num. of unexplored actions: ' num2str(num_unexplored_actions_decreasing_mean) '/' num2str(num_possible_actions)])
    disp(['  � Iteration where optimal action was found: ' num2str(iteration_opt_decreasing_mean(epsilon_ix)) '/' num2str(num_iterations)])
    disp(['  � Iteration where all actions were tried: ' num2str(iteration_all_actions_explored_decreasing_mean(epsilon_ix)) '/' num2str(num_iterations)])
  
end

% Plot evolution of consumption (should decrease with time)


for epsilon_ix = 1:length(epsilon_initial)
    legend_constant{epsilon_ix} = strcat('\epsilon_{cnt}: ', num2str(epsilon_initial(epsilon_ix)));
    legend_decreasing{epsilon_ix} = strcat('\epsilon_{dec}: ', num2str(epsilon_initial(epsilon_ix)));
    legend_both_epsilons{epsilon_ix} = strcat('\epsilon_{cnt}: ', num2str(epsilon_initial(epsilon_ix)));
    legend_both_epsilons{epsilon_ix + length(epsilon_initial)} = strcat('\epsilon_{dec}: ', num2str(epsilon_initial(epsilon_ix)));
end

figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', (btle_history_constant_mean(epsilon_ix,:,2))');
end
title('Learning with CONSTANT \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Bottleneck energy [mJ]')
legend(legend_constant);

figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', (btle_history_decreasing_mean(epsilon_ix,:,2))');
end
title('Learning with DECREASING \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Bottleneck energy [mJ]')
legend(legend_decreasing);

figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', (btle_history_constant_mean(epsilon_ix,:,2))');
end
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', (btle_history_decreasing_mean(epsilon_ix,:,2))');
end
title('Learning with \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Bottleneck energy [mJ]')
legend(legend_both_epsilons);


figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', cumsum(btle_history_constant_mean(epsilon_ix,:,2))');
end
title('Consumption with CONSTANT \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Cummulative bottleneck energy [mJ]')
legend(legend_constant);

figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', cumsum(btle_history_decreasing_mean(epsilon_ix,:,2))');
end
title('Consumption with DECREASING \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Cummulative bottleneck energy [mJ]')
legend(legend_decreasing);

figure
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', cumsum(btle_history_constant_mean(epsilon_ix,:,2))');
end
hold on
for epsilon_ix = 1:length(epsilon_initial)
    plot((1:num_iterations)', cumsum(btle_history_decreasing_mean(epsilon_ix,:,2))');
end
title('Consumption with \epsilon - greedy')
xlabel('time [iterations]')
ylabel('Cummulative bottleneck energy [mJ]')
legend(legend_both_epsilons);

% Call script for displaying results
%display_and_plot_learning


% % Actions histogram
% actions_selected_constant = actions_history(:,1)';
% 
% figure
% histogram(actions_selected_constant, num_possible_actions)
% title('Histogram of actions selected')
% xlabel('Action index')
% ylabel('Number of times picked')

save('learning.mat')