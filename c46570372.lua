--鎮魂の決闘
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方可以从自身墓地选这个回合被战斗破坏的1只怪兽攻击表示特殊召唤。这个效果让自己特殊召唤的怪兽是「元素英雄 新宇侠」的场合，这个回合，那只怪兽和对方怪兽进行战斗的伤害步骤内，那只怪兽的攻击力变成2倍。
function c46570372.initial_effect(c)
	-- 将「元素英雄 新宇侠」的卡号89943723记录到本卡的代码列表中，用于支持“这张卡上记载着「元素英雄 新宇侠」”的判定。
	aux.AddCodeList(c,89943723)
	-- 为本卡注册“元素英雄”系列字段0x3008，用于支持效果中“「元素英雄 新宇侠」”相关卡名/系列判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 这个卡名的卡在1回合只能发动1张。①：双方可以从自身墓地选这个回合被战斗破坏的1只怪兽攻击表示特殊召唤。这个效果让自己特殊召唤的怪兽是「元素英雄 新宇侠」的场合，这个回合，那只怪兽和对方怪兽进行战斗的伤害步骤内，那只怪兽的攻击力变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46570372+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c46570372.target)
	e1:SetOperation(c46570372.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选出这个回合被战斗破坏、且可以被当前效果以表侧攻击表示特殊召唤的墓地怪兽。
function c46570372.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时点检查：自己或对方的主要怪兽区有空位，且对应玩家墓地存在满足过滤条件的怪兽，才可发动。
function c46570372.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c46570372.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()))
		-- 检查对方场上是否有可用的主要怪兽区空格。
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c46570372.filter,tp,0,LOCATION_GRAVE,1,nil,e,1-tp,Duel.GetTurnCount())) end
	-- 设置本连锁的操作信息：效果包含特殊召唤，涉及双方墓地，预计处理1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：双方依次选择自己墓地中符合条件的1只怪兽攻击表示特殊召唤；若自己特殊召唤的是「元素英雄 新宇侠」，则给那只怪兽附加伤害步骤内攻击力变成2倍的效果。
function c46570372.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上存在可用的主要怪兽区空格，则处理自己一侧的特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己墓地中满足条件且不受王家长眠之谷影响的怪兽集合。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46570372.filter),tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
		-- 若存在可选怪兽且玩家选择“是”，则继续选择要特殊召唤的怪兽。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(46570372,0)) then  --"是否从墓地特殊召唤？"
			-- 向自己发送选择卡片的提示，提示内容为“请选择要特殊召唤的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 以表侧攻击表示将自己选择的怪兽特殊召唤（作为特殊召唤处理的一部分）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			if tc:IsCode(89943723) then
				-- 这个效果让自己特殊召唤的怪兽是「元素英雄 新宇侠」的场合，这个回合，那只怪兽和对方怪兽进行战斗的伤害步骤内，那只怪兽的攻击力变成2倍。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetRange(LOCATION_MZONE)
				e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e1:SetCondition(c46570372.atkcon)
				e1:SetValue(c46570372.atkval)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
	-- 若对方场上存在可用的主要怪兽区空格，则处理对方一侧的特殊召唤。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0 then
		-- 获取对方墓地中满足条件且不受王家长眠之谷影响的怪兽集合。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46570372.filter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp,Duel.GetTurnCount())
		-- 若存在可选怪兽且对方玩家选择“是”，则继续选择要特殊召唤的怪兽。
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(46570372,0)) then  --"是否从墓地特殊召唤？"
			-- 向对方发送选择卡片的提示，提示内容为“请选择要特殊召唤的卡”。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(1-tp,1,1,nil):GetFirst()
			-- 以表侧攻击表示将对方选择的怪兽特殊召唤（作为特殊召唤处理的一部分）。
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		end
	end
	-- 完成整个特殊召唤过程，统一处理特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- 攻击力变成2倍效果的发动条件：怪兽在进行战斗的伤害步骤或伤害计算步骤内，且该怪兽是作为攻击怪兽或攻击对象参与战斗。
function c46570372.atkcon(e)
	-- 获取当前所处的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 获取双方正在战斗中的怪兽；a为自己操控的战斗怪兽，d为对方操控的战斗怪兽。
	local a,d=Duel.GetBattleMonster(0)
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and (a==e:GetHandler() and d or a and d==e:GetHandler()) then
		e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
		return true
	end
	return false
end
-- 攻击力变成2倍的值：以该怪兽当前攻击力的2倍作为最终攻击力。
function c46570372.atkval(e,c)
	return e:GetHandler():GetAttack()*2
end
