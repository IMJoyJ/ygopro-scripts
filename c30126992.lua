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
-- 检查玩家墓地是否存在5种类以上的光属性怪兽，满足条件则可以特殊召唤
function c30126992.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 检索玩家墓地所有光属性怪兽
	local g=Duel.GetMatchingGroup(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>4
end
-- 过滤函数，用于筛选可以作为效果发动代价的光属性怪兽
function c30126992.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时，检查玩家墓地是否存在至少1只光属性怪兽并选择除外
function c30126992.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1只光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30126992.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择玩家墓地1只光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c30126992.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡从游戏中除外作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于筛选可以送回卡组的对方场上的盖放卡
function c30126992.filter(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 效果发动时，选择对方场上1张盖放的卡作为对象
function c30126992.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c30126992.filter(chkc) end
	-- 检查对方场上是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingTarget(c30126992.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张盖放的卡作为对象
	local g=Duel.SelectTarget(tp,c30126992.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定将对象卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理时，确认对象卡并选择送回卡组的位置
function c30126992.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 向玩家确认目标卡的卡面信息
		Duel.ConfirmCards(tp,tc)
		-- 检查玩家卡组是否为空
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
			-- 将目标卡送回卡组最底端
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		else
			if tc:IsExtraDeckMonster()
				-- 提示玩家选择将卡送回卡组最上面或最下面
				or Duel.SelectOption(tp,aux.Stringid(30126992,1),aux.Stringid(30126992,2))==0 then  --"返回卡组最上面/返回卡组最下面"
				-- 将目标卡送回卡组最顶端
				Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将目标卡送回卡组最底端
				Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
