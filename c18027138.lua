--カバーカーニバル
-- 效果：
-- ①：在自己场上把3只「河马衍生物」（兽族·地·1星·攻/守0）特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这张卡的发动后，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
function c18027138.initial_effect(c)
	-- ①：在自己场上把3只「河马衍生物」（兽族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c18027138.target)
	e1:SetOperation(c18027138.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认己方未被『青眼精灵龙』的效果影响（该效果禁止双方同时特殊召唤2只以上怪兽），且怪兽区有足够空格并能特殊召唤河马衍生物，才允许发动。
function c18027138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认己方的主要怪兽区域至少存在3个可用空格，用于容纳3只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 确认当前玩家能够将河马衍生物（兽族·地·1星·攻/守0的衍生物）以表侧表示特殊召唤到己方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 设置本次效果处理将生成3只衍生物（token）的操作信息，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置本次效果处理将特殊召唤3只怪兽的操作信息，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理：再次确认条件成立后，循环3次创建河马衍生物并以表侧表示特殊召唤；每只衍生物都被赋予「不能解放」以及「只要该衍生物在怪兽区域存在，控制者不能从额外卡组特殊召唤怪兽」的效果；最后完成特殊召唤。
function c18027138.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 再次确认己方能够特殊召唤河马衍生物，只有满足该条件才执行实际特招处理。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		for i=1,3 do
			-- 创建一只河马衍生物（衍生物怪兽，卡号为18027138+i）。
			local token=Duel.CreateToken(tp,18027138+i)
			-- 将刚创建的衍生物以表侧表示特殊召唤到己方主要怪兽区域，作为连续特殊召唤的其中一步。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 这衍生物不能解放。
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
			-- 只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
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
		-- 完成由多个SpecialSummonStep组成的连续特殊召唤流程，使衍生物正式全部上场。
		Duel.SpecialSummonComplete()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c18027138.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击对象限制效果注册到决斗中，使该限制效果到回合结束前持续适用，归属者为发动者。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判断怪兽是否位于额外卡组，用于「不能从额外卡组把怪兽特殊召唤」的限制。
function c18027138.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：判断攻击对象候选怪兽是否不是「河马衍生物」，即只有非河马衍生物的怪兽才会被限制选为攻击对象。
function c18027138.atlimit(e,c)
	return not c:IsCode(18027139)
end
