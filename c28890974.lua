--光神化
-- 效果：
-- ①：从手卡把1只天使族怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成一半，结束阶段破坏。
function c28890974.initial_effect(c)
	-- 效果原文内容：①：从手卡把1只天使族怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成一半，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28890974.target)
	e1:SetOperation(c28890974.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的天使族怪兽，且该怪兽可以被特殊召唤
function c28890974.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：手卡存在天使族怪兽且场上存在空位
function c28890974.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡是否存在满足条件的天使族怪兽
		and Duel.IsExistingMatchingCard(c28890974.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤1张手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果发动处理：检查是否有空位，提示选择并检索满足条件的怪兽，进行特殊召唤
function c28890974.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c28890974.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local atk=tc:GetAttack()
		-- 执行特殊召唤步骤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果原文内容：这个效果特殊召唤的怪兽的攻击力变成一半
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果原文内容：结束阶段破坏
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetOperation(c28890974.desop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetCountLimit(1)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 破坏效果的处理函数
function c28890974.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽因效果而破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
