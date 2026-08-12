--スケープ・ゴート
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
-- ①：在自己场上把4只「羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c73915051.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。①：在自己场上把4只「羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c73915051.cost)
	e1:SetTarget(c73915051.target)
	e1:SetOperation(c73915051.activate)
	c:RegisterEffect(e1)
end
-- 检查发动回合内，自己是否进行过召唤、反转召唤或特殊召唤。
function c73915051.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否进行过通常召唤。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查本回合自己是否进行过反转召唤或特殊召唤。
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c73915051.sumlimit)
	-- 注册限制特殊召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 注册限制通常召唤的玩家效果。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 注册限制反转召唤的玩家效果。
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的过滤函数，允许本卡的效果进行特殊召唤。
function c73915051.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 效果发动的目标检查，确认是否能特殊召唤4只衍生物。
function c73915051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于3（即至少有4个空位）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>3
		-- 检查玩家是否能特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,73915052,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置在效果处理时产生4个衍生物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,4,0,0)
	-- 设置在效果处理时特殊召唤4只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,0,0)
end
-- 效果处理，在自己场上特殊召唤4只「羊衍生物」并赋予不能为上级召唤而解放的限制。
function c73915051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上是否有4个以上的怪兽区域空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>3
		-- 检查玩家是否能特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,73915052,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		for i=1,4 do
			-- 创建「羊衍生物」卡片。
			local token=Duel.CreateToken(tp,73915051+i)
			-- 将衍生物以表侧守备表示特殊召唤到场上（单步处理）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能为上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤的批量处理。
		Duel.SpecialSummonComplete()
	end
end
