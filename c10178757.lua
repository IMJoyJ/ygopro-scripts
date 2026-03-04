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
-- 定义同调素材限制的Value函数，当同调召唤的怪兽不是「次世代」时返回true（表示不能使用此卡作为素材）
function c10178757.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x2)
end
-- 定义效果①的发动条件函数，检查此卡是否因「次世代」怪兽的效果从卡组加入自己手卡
function c10178757.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)>0 and re:GetHandler():IsSetCard(0x2)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK) and e:GetHandler():IsPreviousControler(tp)
end
-- 定义效果①的目标函数，用于检查是否可以特殊召唤并设置操作信息
function c10178757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明效果处理时要特殊召唤1张卡（此卡本身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果①的操作函数，执行特殊召唤的处理
function c10178757.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
