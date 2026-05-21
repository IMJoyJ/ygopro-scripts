--死の花－ネクロ・フルール
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合才能发动。从卡组把1只「时花之魔女」特殊召唤。
function c99000151.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合才能发动。从卡组把1只「时花之魔女」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99000151,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c99000151.condition)
	e1:SetTarget(c99000151.target)
	e1:SetOperation(c99000151.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否因效果破坏而送去墓地
function c99000151.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 过滤卡组中卡名为「时花之魔女」且可以特殊召唤的怪兽
function c99000151.filter(c,e,tp)
	return c:IsCode(36405256) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查，确认己方场上有空余怪兽区域且卡组中存在可特殊召唤的「时花之魔女」
function c99000151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在可特殊召唤的「时花之魔女」
		and Duel.IsExistingMatchingCard(c99000151.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组将1只「时花之魔女」特殊召唤
function c99000151.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若己方场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从己方卡组中检索第一张符合条件的「时花之魔女」
	local tc=Duel.GetFirstMatchingCard(c99000151.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的「时花之魔女」以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
