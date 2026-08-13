--ライトレイ ディアボロス
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是5种类以上的场合可以特殊召唤。1回合1次，可以把自己墓地1只光属性怪兽从游戏中除外，选择对方场上盖放的1张卡确认，回到持有者卡组最上面或者最下面。
function c30126992.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己墓地的光属性怪兽是5种类以上的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c30126992.spcon)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己墓地1只光属性怪兽从游戏中除外，选择对方场上盖放的1张卡确认，回到持有者卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30126992,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30126992.tdcost)
	e2:SetTarget(c30126992.tdtg)
	e2:SetOperation(c30126992.tdop)
	c:RegisterEffect(e2)
end
-- 若c为nil则直接返回true；否则需满足：控制者主要怪兽区有空位，且墓地中光属性怪兽的卡名种类数大于4（5种类以上）。
function c30126992.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者是否有可用主要怪兽区空格；若没有，则不能特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 取得该控制者墓地中所有光属性怪兽的集合，用于后续统计卡名种类数。
	local g=Duel.GetMatchingGroup(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>4
end
-- 过滤条件：该卡是光属性怪兽，且能够作为发动代价从墓地除外。
function c30126992.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：从自己墓地选择1只光属性怪兽除外。先检查是否存在可用代价卡，然后让玩家选择并执行除外。
function c30126992.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地是否存在至少1张光属性且可除外的卡，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30126992.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要除外的卡”的选择提示，用于后续代价选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足cfilter的光属性怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c30126992.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示从墓地除外，除外原因为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果对象过滤条件：该卡是里侧表示，且可以被返回卡组。
function c30126992.filter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果目标设定：选择对方场上1张里侧表示且可返回卡组的卡作为对象，并设置操作信息为回卡组；同时处理连锁时对象合法性检查。
function c30126992.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c30126992.filter(chkc) end
	-- 目标检查：确认对方场上是否存在至少1张满足条件的里侧表示卡（可回卡组）。
	if chk==0 then return Duel.IsExistingTarget(c30126992.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从对方场上选择1张满足条件的里侧表示卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c30126992.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，声明本效果将要把1张卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象仍与效果关联且仍为里侧表示，则确认该卡；若当前玩家卡组为0则直接回底端，否则让玩家选择回顶或回底并执行相应返回操作。
function c30126992.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡（即对方场上被选中的里侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将对象卡展示给当前玩家确认（翻开该里侧卡让玩家看到）。
		Duel.ConfirmCards(tp,tc)
		-- 检查当前玩家的卡组数量是否为0；若是，则强制返回卡组底端，不提供选择。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
			-- 当当前玩家卡组为0时，将对象卡以效果原因返回其持有者卡组最底端。
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		else
			if tc:IsExtraDeckMonster()
				-- 若对象卡是额外卡组怪兽，或玩家选择“返回卡组最上面”，则执行返回顶端。
				or Duel.SelectOption(tp,aux.Stringid(30126992,1),aux.Stringid(30126992,2))==0 then  --"返回卡组最上面/返回卡组最下面"
				-- 将对象卡以效果原因返回其持有者卡组最顶端（对应选择返回最上面或额外卡组怪兽的情况）。
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将对象卡以效果原因返回其持有者卡组最底端（对应玩家选择返回最下面的情况）。
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
