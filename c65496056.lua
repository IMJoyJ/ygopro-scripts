--コダロス
-- 效果：
-- 把自己场上表侧表示存在的「海」送去墓地才能发动。选择对方场上最多2张卡送去墓地。
function c65496056.initial_effect(c)
	-- 记录该卡的效果中记有「海」（卡片密码：22702055）
	aux.AddCodeList(c,22702055)
	-- 把自己场上表侧表示存在的「海」送去墓地才能发动。选择对方场上最多2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65496056,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c65496056.cost)
	e1:SetTarget(c65496056.target)
	e1:SetOperation(c65496056.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示存在的「海」且能作为代价送去墓地
function c65496056.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055) and c:IsAbleToGraveAsCost()
end
-- 发动代价（Cost）处理：把自己场上表侧表示存在的「海」送去墓地
function c65496056.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否存在至少1张满足条件的「海」
	if chk==0 then return Duel.IsExistingMatchingCard(c65496056.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张满足条件的「海」
	local g=Duel.SelectMatchingCard(tp,c65496056.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的「海」作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标（Target）处理：选择对方场上最多2张卡
function c65496056.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToGrave() end
	-- 在发动检测阶段，检查对方场上是否存在至少1张可以送去墓地的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1到2张可以送去墓地的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置当前连锁的操作信息为：将选中的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理（Operation）处理：将选择的卡送去墓地
function c65496056.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
