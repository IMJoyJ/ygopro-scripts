--再機動
-- 效果：
-- 从自己手卡让1只名字带有「机皇」的怪兽回到卡组发动。选择自己墓地存在的1张名字带有「机皇」的卡加入手卡。
function c85775486.initial_effect(c)
	-- 从自己手卡让1只名字带有「机皇」的怪兽回到卡组发动。选择自己墓地存在的1张名字带有「机皇」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c85775486.cost)
	e1:SetTarget(c85775486.target)
	e1:SetOperation(c85775486.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中名字带有「机皇」的怪兽且能回到卡组
function c85775486.cfilter(c)
	return c:IsSetCard(0x13) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- 发动代价（Cost）处理：从手卡让1只「机皇」怪兽回到卡组
function c85775486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的「机皇」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85775486.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择手卡中1只满足条件的「机皇」怪兽
	local g=Duel.SelectMatchingCard(tp,c85775486.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：墓地中名字带有「机皇」且能加入手卡的卡
function c85775486.filter(c)
	return c:IsSetCard(0x13) and c:IsAbleToHand()
end
-- 效果的目标（Target）处理：选择墓地1张「机皇」卡为对象
function c85775486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85775486.filter(chkc) end
	-- 检查墓地是否存在满足条件的「机皇」卡
	if chk==0 then return Duel.IsExistingTarget(c85775486.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中1张「机皇」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c85775486.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理（Operation）：将对象卡加入手牌并给对方确认
function c85775486.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
