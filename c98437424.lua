--ナチュル・コスモスビート
-- 效果：
-- 对方对怪兽的通常召唤成功时，这张卡可以从手卡特殊召唤。
function c98437424.initial_effect(c)
	-- 对方对怪兽的通常召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98437424,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c98437424.spcon)
	e1:SetTarget(c98437424.sptg)
	e1:SetOperation(c98437424.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
end
-- 检查通常召唤（或盖放）怪兽的玩家是否为对方
function c98437424.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 检查自身是否可以特殊召唤，且自己场上是否有可用的怪兽区域
function c98437424.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将这张卡从手卡特殊召唤的效果处理
function c98437424.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
