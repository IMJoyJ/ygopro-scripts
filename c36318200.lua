--森の聖獣 ユニフォリア
-- 效果：
-- 自己墓地的怪兽只有兽族的场合，把这张卡解放才能发动。从自己的手卡·墓地选「森之圣兽 绿叶独角兽」以外的1只兽族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c36318200.initial_effect(c)
	-- 效果原文：自己墓地的怪兽只有兽族的场合，把这张卡解放才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36318200,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c36318200.spcon)
	e1:SetCost(c36318200.spcost)
	e1:SetTarget(c36318200.sptg)
	e1:SetOperation(c36318200.spop)
	c:RegisterEffect(e1)
end
-- 效果原文：从自己的手卡·墓地选「森之圣兽 绿叶独角兽」以外的1只兽族怪兽特殊召唤。
function c36318200.cfilter(c)
	return c:GetRace()~=RACE_BEAST
end
-- 效果原文：这个效果特殊召唤的怪兽在这个回合不能攻击。
function c36318200.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(c36318200.cfilter,1,nil)
end
-- 将目标怪兽特殊召唤
function c36318200.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将目标怪兽特殊召唤
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 将目标怪兽特殊召唤
function c36318200.filter(c,e,tp)
	return not c:IsCode(36318200) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 将目标怪兽特殊召唤
function c36318200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 将目标怪兽特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 将目标怪兽特殊召唤
		and Duel.IsExistingMatchingCard(c36318200.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 将目标怪兽特殊召唤
function c36318200.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 将目标怪兽特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 将目标怪兽特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36318200.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将目标怪兽特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文：这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 将目标怪兽特殊召唤
	Duel.SpecialSummonComplete()
end
