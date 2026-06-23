--鎮魂の決闘
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方可以从自身墓地选这个回合被战斗破坏的1只怪兽攻击表示特殊召唤。这个效果让自己特殊召唤的怪兽是「元素英雄 新宇侠」的场合，这个回合，那只怪兽和对方怪兽进行战斗的伤害步骤内，那只怪兽的攻击力变成2倍。
function c46570372.initial_effect(c)
	-- 记录该卡牌效果中涉及的「元素英雄 新宇侠」的卡片密码
	aux.AddCodeList(c,89943723)
	-- 为该卡牌添加「元素英雄」系列编码，用于后续判断是否为该系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：双方可以从自身墓地选这个回合被战斗破坏的1只怪兽攻击表示特殊召唤。这个效果让自己特殊召唤的怪兽是「元素英雄 新宇侠」的场合，这个回合，那只怪兽和对方怪兽进行战斗的伤害步骤内，那只怪兽的攻击力变成2倍。
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
-- 过滤函数：检查墓地中的怪兽是否为本回合被战斗破坏且可以特殊召唤
function c46570372.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 目标函数：判断是否满足发动条件，即任意一方场上存在可特殊召唤的墓地被战斗破坏的怪兽
function c46570372.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上有空位
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c46570372.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount()))
		-- 判断对方场上有空位
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断对方墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c46570372.filter,tp,0,LOCATION_GRAVE,1,nil,e,1-tp,Duel.GetTurnCount())) end
	-- 设置连锁操作信息，提示将要特殊召唤墓地中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 发动函数：处理双方从墓地特殊召唤被战斗破坏的怪兽，并对新宇侠设置攻击力翻倍效果
function c46570372.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取满足条件的墓地怪兽组（排除王家长眠之谷影响）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46570372.filter),tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
		-- 判断是否有符合条件的怪兽且玩家选择发动
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(46570372,0)) then  --"是否从墓地特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 执行特殊召唤操作，将选中的怪兽以攻击表示特殊召唤到自己场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			if tc:IsCode(89943723) then
				-- 若特殊召唤的是「元素英雄 新宇侠」，则设置其攻击力翻倍效果
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
	-- 判断对方场上有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0 then
		-- 获取满足条件的对方墓地怪兽组（排除王家长眠之谷影响）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c46570372.filter),1-tp,LOCATION_GRAVE,0,nil,e,1-tp,Duel.GetTurnCount())
		-- 判断是否有符合条件的怪兽且对方选择发动
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(46570372,0)) then  --"是否从墓地特殊召唤？"
			-- 提示对方玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(1-tp,1,1,nil):GetFirst()
			-- 执行特殊召唤操作，将选中的怪兽以攻击表示特殊召唤到对方场上
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 判断是否处于伤害步骤或伤害计算阶段，并确认是否为当前怪兽参与战斗
function c46570372.atkcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前战斗中的双方怪兽
	local a,d=Duel.GetBattleMonster(0)
	if (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and (a==e:GetHandler() and d or a and d==e:GetHandler()) then
		e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
		return true
	end
	return false
end
-- 返回当前怪兽攻击力的两倍
function c46570372.atkval(e,c)
	return e:GetHandler():GetAttack()*2
end
