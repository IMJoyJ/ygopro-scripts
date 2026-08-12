--ワイトキング
-- 效果：
-- ①：这张卡的原本攻击力变成自己墓地的「白骨王」「白骨」数量×1000。
-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只其他的「白骨王」或「白骨」除外才能发动。这张卡特殊召唤。
function c36021814.initial_effect(c)
	-- 注册卡片代码列表，记录该卡具有「白骨王」和「白骨」的卡片密码
	aux.AddCodeList(c,32274490)
	-- ①：这张卡的原本攻击力变成自己墓地的「白骨王」「白骨」数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c36021814.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时，从自己墓地把1只其他的「白骨王」或「白骨」除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36021814,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c36021814.condition)
	e2:SetCost(c36021814.cost)
	e2:SetTarget(c36021814.target)
	e2:SetOperation(c36021814.operation)
	c:RegisterEffect(e2)
end
-- 计算自身墓地中的「白骨王」和「白骨」的数量并乘以1000作为攻击力
function c36021814.atkval(e,c)
	-- 获取自己墓地中「白骨王」和「白骨」的数量并乘以1000
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,32274490,36021814)*1000
end
-- 判断该卡是否因战斗破坏而进入墓地
function c36021814.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 过滤函数，用于判断墓地中的卡是否为「白骨王」或「白骨」且可作为除外的代价
function c36021814.costfilter(c)
	return c:IsCode(32274490,36021814) and c:IsAbleToRemoveAsCost()
end
-- 支付除外代价，从墓地选择1只「白骨王」或「白骨」除外
function c36021814.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外代价的条件，即墓地是否存在至少1只「白骨王」或「白骨」
	if chk==0 then return Duel.IsExistingMatchingCard(c36021814.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的卡作为除外代价
	local g=Duel.SelectMatchingCard(tp,c36021814.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤的条件，检查是否有足够的召唤位置和是否可以特殊召唤
function c36021814.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡特殊召唤到场上
function c36021814.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
