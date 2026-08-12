--赤鬼
-- 效果：
-- 这张卡召唤成功时，可以把自己手卡任意数量送去墓地，那个数量的场上的卡回到持有者手卡。
function c68722455.initial_effect(c)
	-- 这张卡召唤成功时，可以把自己手卡任意数量送去墓地，那个数量 of 场上的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68722455,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c68722455.cost)
	e1:SetTarget(c68722455.target)
	e1:SetOperation(c68722455.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以作为代价送去墓地的卡
function c68722455.costfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 代价处理：选择手卡任意数量的卡送去墓地，并记录送去墓地的数量
function c68722455.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以作为代价送去墓地的卡（自身除外）
	if chk==0 then return Duel.IsExistingMatchingCard(c68722455.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 计算场上可以成为效果对象并能回到手牌的卡片数量，以此作为送去墓地卡片数量的上限
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张到rt张手卡中满足过滤条件的卡
	local cg=Duel.SelectMatchingCard(tp,c68722455.costfilter,tp,LOCATION_HAND,0,1,rt,nil)
	-- 将选择的手卡作为代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
	e:SetLabel(cg:GetCount())
end
-- 效果的目标选择：选择与送去墓地数量相同的场上的卡作为效果对象
function c68722455.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在至少1张可以回到手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与送去墓地数量（ct）相同的场上的卡作为效果对象
	local eg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置操作信息：将指定数量的对象卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,ct,0,0)
end
-- 效果处理：将作为效果对象的卡送回持有者手牌
function c68722455.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 将仍存在于场上且与效果相关的卡片送回持有者手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
