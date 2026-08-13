--電光千鳥
-- 效果：
-- 风属性4星怪兽×2
-- 这张卡超量召唤成功时，选择对方场上盖放的1张卡回到持有者卡组最下面。此外，1回合1次，把这张卡1个超量素材取除才能发动。选择对方场上表侧表示存在的1张卡回到持有者卡组最上面。
function c22653490.initial_effect(c)
	-- 为这张卡添加超量召唤手续，召唤条件为风属性4星怪兽2只叠放。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),4,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，选择对方场上盖放的1张卡回到持有者卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22653490,0))  --"返回卡组最下面"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c22653490.tdcon1)
	e1:SetTarget(c22653490.tdtg1)
	e1:SetOperation(c22653490.tdop1)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把这张卡1个超量素材取除才能发动。选择对方场上表侧表示存在的1张卡回到持有者卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22653490,1))  --"返回卡组最上面"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c22653490.tdcost2)
	e2:SetTarget(c22653490.tdtg2)
	e2:SetOperation(c22653490.tdop2)
	c:RegisterEffect(e2)
end
-- 诱发效果的发动条件：效果发动者为超量召唤成功的这张卡自身（即这张卡以超量召唤方式出场时满足条件）。
function c22653490.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选对象卡的条件：对方场上里侧表示且可以送去卡组的卡。
function c22653490.tdfilter1(c)
	return c:IsFacedown() and c:IsAbleToDeck()
end
-- 第一个效果的发动时处理：必发效果无需发动条件；确认对象为对方场上的里侧表示卡，并选择其中1张作为效果对象，同时设置回卡组的操作信息。
function c22653490.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c22653490.tdfilter1(chkc) end
	if chk==0 then return true end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上里侧表示的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将所选择的对象卡执行回卡组处理，数量为选择卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 第一个效果处理时：从效果对象中取得目标卡，若该卡仍在场上且与效果关联、仍为对方场上的里侧表示卡，则将其返回持有者卡组最下面。
function c22653490.tdop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 以效果原因将目标卡返回持有者卡组最下面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 第二个效果的发动代价：检查并实际移除这张卡的1个超量素材。
function c22653490.tdcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选对象卡的条件：对方场上表侧表示且可以送去卡组的卡。
function c22653490.tdfilter2(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
-- 第二个效果的发动时处理：确认指定对象合法；检查对方场上是否存在符合条件的卡，然后提示并选择对方场上表侧表示的1张卡作为对象，设置回卡组的操作信息。
function c22653490.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c22653490.tdfilter2(chkc) end
	-- 发动条件检查：对方场上是否存在1张表侧表示且可以返回卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(c22653490.tdfilter2,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上表侧表示的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22653490.tdfilter2,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将所选择的对象卡执行回卡组处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 第二个效果处理时：取得对象卡，若该卡仍在场上且与效果关联、仍为对方场上的表侧表示卡，则将其返回持有者卡组最上面。
function c22653490.tdop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第二个效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 以效果原因将目标卡返回持有者卡组最上面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
