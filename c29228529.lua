--魔法再生
-- 效果：
-- 将自己手卡中的2张魔法卡送去墓地。从自己墓地里选择1张魔法卡加入手卡。
function c29228529.initial_effect(c)
	-- 将自己手卡中的2张魔法卡送去墓地。从自己墓地里选择1张魔法卡加入手卡。
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
-- 定义代价筛选函数：判定一张卡是否为魔法卡，且是否可以作为代价从手牌送去墓地。
function c29228529.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 定义代价处理函数：在发动前检查能否支付代价，并在发动时从手牌将2张符合条件的魔法卡丢弃作为代价。
function c29228529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）时，检查自己手牌中是否存在至少2张满足costfilter条件的魔法卡（可作为代价送去墓地）。
	if chk==0 then return Duel.IsExistingMatchingCard(c29228529.costfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 执行丢弃代价：从手牌中选择2张满足costfilter条件的魔法卡，以代价形式丢弃到墓地。
	Duel.DiscardHand(tp,c29228529.costfilter,2,2,REASON_COST)
end
-- 定义对象筛选函数：判定墓地中的一张卡是否为魔法卡，且是否可以加入手牌。
function c29228529.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 定义效果发动时的目标选择与登记阶段：选择自己墓地中的1张魔法卡为对象，并设置回手牌的操作信息。
function c29228529.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29228529.filter(chkc) end
	-- 在目标检查阶段（chk==0）时，检查自己墓地中是否存在至少1张满足filter条件的魔法卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c29228529.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的满足filter条件的魔法卡中选择1张作为效果对象。
	local g=Duel.SelectTarget(tp,c29228529.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁的操作信息：将所选对象卡加入手牌，数量为选择张数（1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：在效果结算时将所选对象卡加入手牌，并让对方确认那张卡。
function c29228529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中登记的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡送回去其持有者的手牌（以效果处理为原因）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手牌的魔法卡，以确认其卡名等信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
