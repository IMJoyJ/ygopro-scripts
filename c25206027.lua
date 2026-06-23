--異界の棘紫竜
-- 效果：
-- 自己场上的怪兽被战斗或者卡的效果破坏送去墓地的场合，这张卡可以从手卡特殊召唤。
function c25206027.initial_effect(c)
	-- 自己场上的怪兽被战斗或者卡的效果破坏送去墓地的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25206027,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c25206027.spcon)
	e1:SetTarget(c25206027.sptg)
	e1:SetOperation(c25206027.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：被破坏、之前在主要怪兽区、之前控制者为自己、怪兽卡
function c25206027.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 连锁条件：确认有满足过滤条件的卡被送去墓地
function c25206027.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25206027.spfilter,1,nil,tp)
end
-- 效果处理时的确认条件：场上存在空位且自身可以特殊召唤
function c25206027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将自身特殊召唤
function c25206027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将自身特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
