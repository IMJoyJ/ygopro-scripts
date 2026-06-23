--黄泉ガエル
-- 效果：
-- ①：这张卡在墓地存在，自己场上没有「黄泉青蛙」存在的场合，自己准备阶段才能发动。这张卡特殊召唤。这个效果在自己场上没有魔法·陷阱卡存在的场合才能发动和处理。
function c12538374.initial_effect(c)
	-- ①：这张卡在墓地存在，自己场上没有「黄泉青蛙」存在的场合，自己准备阶段才能发动。这张卡特殊召唤。这个效果在自己场上没有魔法·陷阱卡存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12538374,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c12538374.condition)
	e1:SetTarget(c12538374.target)
	e1:SetOperation(c12538374.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在魔法·陷阱卡或表侧表示的黄泉青蛙
function c12538374.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsCode(12538374) and c:IsFaceup())
end
-- 效果的发动条件函数，判断是否满足发动条件
function c12538374.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前回合玩家为发动者且场上没有魔法·陷阱卡或表侧表示的黄泉青蛙
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c12538374.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果的目标设定函数
function c12538374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查准备阶段是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断场上是否存在魔法·陷阱卡
function c12538374.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的处理函数，执行特殊召唤操作
function c12538374.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡片是否仍存在于场上且场上没有魔法·陷阱卡
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c12538374.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 将该卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
