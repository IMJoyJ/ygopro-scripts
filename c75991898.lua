--ラヴァルバル・ドラゴン
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- ①：让自己墓地2只「熔岩」怪兽回到卡组，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c75991898.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的炎属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：让自己墓地2只「熔岩」怪兽回到卡组，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75991898,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75991898.cost)
	e1:SetTarget(c75991898.target)
	e1:SetOperation(c75991898.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地可以回到卡组的「熔岩」怪兽
function c75991898.costfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToDeckAsCost()
end
-- 代价（Cost）处理函数：让自己墓地2只「熔岩」怪兽回到卡组
function c75991898.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己墓地是否存在至少2只可以回到卡组的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75991898.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地2只可以回到卡组的「熔岩」怪兽
	local g=Duel.SelectMatchingCard(tp,c75991898.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 为选择的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选择的怪兽作为代价返回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 目标选择（Target）处理函数
function c75991898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在发动阶段检查对方场上是否存在至少1张可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理（Operation）函数
function c75991898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
