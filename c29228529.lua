--魔法再生
-- 效果：
-- 将自己手卡中的2张魔法卡送去墓地。从自己墓地里选择1张魔法卡加入手卡。
function c29228529.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌，设置为取对象效果，设置为魔陷发动，设置为自由时点，设置效果的费用、目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c29228529.cost)
	e1:SetTarget(c29228529.target)
	e1:SetOperation(c29228529.operation)
	c:RegisterEffect(e1)
end
-- 费用过滤函数，检查卡片是否为魔法卡且可以作为代价送去墓地
function c29228529.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果的费用处理函数，检查是否满足条件并丢弃2张手牌中的魔法卡作为代价
function c29228529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件，即手牌中是否存在至少2张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29228529.costfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 执行丢弃手牌操作，丢弃2张满足条件的魔法卡作为代价
	Duel.DiscardHand(tp,c29228529.costfilter,2,2,REASON_COST)
end
-- 目标过滤函数，检查卡片是否为魔法卡且可以加入手牌
function c29228529.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果的目标处理函数，设置选择墓地中的魔法卡作为目标
function c29228529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29228529.filter(chkc) end
	-- 检查是否满足目标条件，即墓地中是否存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingTarget(c29228529.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标，从墓地中选择1张魔法卡作为目标
	local g=Duel.SelectTarget(tp,c29228529.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，确定效果处理时将要回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果的处理函数，将选择的卡加入手牌并确认对方查看
function c29228529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认查看该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
