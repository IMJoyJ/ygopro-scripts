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
-- 筛选送去墓地的怪兽是否满足：被破坏、之前在场地区域、之前由自己控制、并且是怪兽卡。
function c25206027.spfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 诱发效果的发动条件：本次送去墓地的怪兽中存在满足上述筛选条件的怪兽。
function c25206027.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25206027.spfilter,1,nil,tp)
end
-- 发动时的合法性检查：自己场上有可用的主要怪兽区空格，且手牌中的这张卡能够被特殊召唤。
function c25206027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息登记为特殊召唤这张卡，便于其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与效果关联，则将其正面表示特殊召唤到自己场上。
function c25206027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以正面表示形式特殊召唤到自己场上，不检查召唤条件且不限制苏生。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
