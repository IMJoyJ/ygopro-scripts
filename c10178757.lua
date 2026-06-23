--レアル・ジェネクス・オラクル
-- 效果：
-- 把这张卡作为同调素材的场合，不是「次世代」怪兽的同调召唤不能使用。
-- ①：这张卡用「次世代」怪兽的效果从自己卡组加入手卡的场合才能发动。这张卡特殊召唤。
function c10178757.initial_effect(c)
	-- ①：这张卡用「次世代」怪兽的效果从自己卡组加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10178757,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c10178757.condition)
	e1:SetTarget(c10178757.target)
	e1:SetOperation(c10178757.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是「次世代」怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c10178757.synlimit)
	c:RegisterEffect(e2)
end
-- 作为同调素材时限制只能用于「次世代」怪兽的同调召唤
function c10178757.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x2)
end
-- 触发条件：因「次世代」怪兽的效果从卡组加入手卡
function c10178757.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)>0 and re:GetHandler():IsSetCard(0x2)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsPreviousControler(tp)
end
-- 判定自己场上是否有空余的怪兽区域且此卡可以特殊召唤
function c10178757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：此卡特殊召唤
function c10178757.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
