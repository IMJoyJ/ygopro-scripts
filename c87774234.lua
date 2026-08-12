--ワタポン
-- 效果：
-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。
function c87774234.initial_effect(c)
	-- 这张卡被魔法·陷阱·效果怪兽的效果从自己卡组加入手卡的场合，这张卡可以在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87774234,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c87774234.condition)
	e1:SetTarget(c87774234.target)
	e1:SetOperation(c87774234.operation)
	c:RegisterEffect(e1)
end
-- 检查触发原因是否为效果，且该卡之前的位置是否是自己的卡组（即被效果从自己卡组加入手卡）
function c87774234.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsPreviousControler(tp)
end
-- 检查发动效果的条件：自己场上有可用的怪兽区域，且该卡可以被特殊召唤
function c87774234.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：如果该卡仍与效果存在关联，则将该卡在自己场上特殊召唤
function c87774234.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡在自己场上以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
