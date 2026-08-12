--薔薇恋人
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从手卡把1只植物族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不受对方的陷阱卡的效果影响。
function c89252157.initial_effect(c)
	-- ①：把墓地的这张卡除外才能发动。从手卡把1只植物族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不受对方的陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,89252157)
	-- 将墓地的这张卡除外作为发动的Cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c89252157.sptg)
	e1:SetOperation(c89252157.spop)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以特殊召唤的植物族怪兽
function c89252157.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c89252157.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足特殊召唤条件的植物族怪兽
		and Duel.IsExistingMatchingCard(c89252157.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息为从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理（特殊召唤及赋予不受陷阱卡影响的抗性）
function c89252157.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c89252157.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则尝试将其以表侧表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不受对方的陷阱卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c89252157.efilter)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 免疫效果的过滤函数，限定为对方发动的陷阱卡的效果
function c89252157.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_TRAP)
end
