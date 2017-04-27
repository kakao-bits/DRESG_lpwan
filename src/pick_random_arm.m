function [ picked_arm ] = pick_random_arm( reward_per_arm, only_unknown )
    %PICK_RANDOM_ARM Summary of this function goes here
    %   Detailed explanation goes here
    
    [reward, picked_arm] = datasample(reward_per_arm, 1);   % Sample uniformely at random
    
    % OPTIMIZATION NEEDED FOR LARGER COMBINATIONS!
    if only_unknown
        unkown_elements = find(reward_per_arm == -1);
        if ~isempty(unkown_elements)
            picked_arm = datasample(unkown_elements, 1);
        else
            %disp('There are not unknown elements! Picking one of the bests')
            [max_reward, ~]= max(reward_per_arm);
            % If there is more than one best known arm
            %disp('   ? array_best_known_arms: ')
            array_best_known_arms = find(reward_per_arm == max_reward);
            %disp(array_best_known_arms)
            random_best_arm_ix = ceil(rand(1)*length(array_best_known_arms));
            %disp(['   ? random_best_arm_ix: ' num2str(random_best_arm_ix) '/' num2str(length(array_best_known_arms))])
            picked_arm = array_best_known_arms(random_best_arm_ix);        
        end
    end
    
end

