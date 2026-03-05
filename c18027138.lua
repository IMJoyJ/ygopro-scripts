--カバーカーニバル
-- 效果：
-- ①：在自己场上把3只「河马衍生物」（兽族·地·1星·攻/守0）特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这张卡的发动后，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
function c18027138.initial_effect(c)
	-- 效果原文内容：①：在自己场上把3只「河马衍生物」（兽族·地·1星·攻/守0）特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这张卡的发动后，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c18027138.target)
	e1:SetOperation(c18027138.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检测是否可以发动此卡，包括确认玩家未受青眼精灵龙效果影响、场上怪兽区域有足够空位、可以特殊召唤河马衍生物。
function c18027138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果作用：检测玩家场上怪兽区域是否有至少3个空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 效果作用：检测玩家是否可以特殊召唤指定的河马衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤3个衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤3个河马衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果作用：执行卡牌效果，包括创建并特殊召唤3个河马衍生物，并为每个衍生物设置不能解放和不能从额外卡组特殊召唤的限制。
function c18027138.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 效果作用：检测玩家是否可以特殊召唤河马衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		for i=1,3 do
			-- 效果作用：创建一个河马衍生物。
			local token=Duel.CreateToken(tp,18027138+i)
			-- 效果作用：将河马衍生物特殊召唤到场上。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 效果原文内容：这衍生物不能解放。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2)
			-- 效果原文内容：只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetRange(LOCATION_MZONE)
			e3:SetAbsoluteRange(tp,1,0)
			e3:SetTarget(c18027138.splimit)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e3)
		end
		-- 效果作用：完成所有特殊召唤步骤。
		Duel.SpecialSummonComplete()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文内容：这张卡的发动后，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c18027138.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：注册一个效果，使对方不能选择河马衍生物以外的怪兽作为攻击目标。
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：限制不能从额外卡组特殊召唤。
function c18027138.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 效果作用：限制对方不能选择非河马衍生物作为攻击目标。
function c18027138.atlimit(e,c)
	return not c:IsCode(18027139)
end
