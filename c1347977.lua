--聖なる守り手
-- 效果：
-- ①：这张卡反转的场合，从以下效果选择1个发动。
-- ●以场上1只表侧表示怪兽为对象发动。那只表侧表示怪兽回到持有者卡组最上面。
-- ●自己场上有战士族怪兽存在的场合，以场上2只表侧表示怪兽为对象发动。那1只表侧表示怪兽回到持有者卡组最上面。那之后，自己场上有战士族怪兽存在的场合，另1只表侧表示怪兽回到持有者手卡。
function c1347977.initial_effect(c)
	-- 对应效果原文：①：这张卡反转的场合，从以下效果选择1个发动。●以场上1只表侧表示怪兽为对象发动。那只表侧表示怪兽回到持有者卡组最上面。●自己场上有战士族怪兽存在的场合，以场上2只表侧表示怪兽为对象发动。那1只表侧表示怪兽回到持有者卡组最上面。那之后，自己场上有战士族怪兽存在的场合，另1只表侧表示怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1347977,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1347977.target)
	e1:SetOperation(c1347977.activate)
	c:RegisterEffect(e1)
end
-- 过滤出场上表侧表示、可送去卡组的怪兽，作为回卡组效果的对象选择条件。
function c1347977.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤出场上表侧表示、可加入手卡的怪兽，作为回手牌效果的对象选择条件。
function c1347977.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤出自己场上表侧表示的战士族怪兽，用于判断是否能选择第二项效果。
function c1347977.filter3(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 反转效果发动时，先选择1只场上表侧表示可回卡组的怪兽；若自己场上有战士族怪兽、场上存在可回手牌的怪兽且玩家选择“是”，则再选择1只回手牌的怪兽，并设置对应的操作信息。
function c1347977.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方场上选择1只满足filter1的表侧表示怪兽，将其设为效果对象（回卡组）。
	local g1=Duel.SelectTarget(tp,c1347977.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g1:GetCount()==0 then return end
	-- 登记将1张卡返回卡组的操作信息，供后续效果处理及连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	-- 检查自己场上是否有表侧表示的战士族怪兽，以决定能否选择第二个效果。
	if Duel.IsExistingMatchingCard(c1347977.filter3,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否存在除已选回卡组对象以外的、可作为回手牌对象的表侧表示怪兽。
		and Duel.IsExistingTarget(c1347977.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,g1:GetFirst())
		-- 询问玩家是否追加选择1只怪兽返回手牌（选择“是”则执行第二个选项的追加处理）。
		and Duel.SelectYesNo(tp,aux.Stringid(1347977,1)) then  --"是否要再选择场上的1只表侧表示的怪兽回到手卡？"
		-- 提示玩家选择要返回手牌的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 从双方场上选择1只满足filter2的表侧表示怪兽，将其设为回手牌效果对象。
		local g2=Duel.SelectTarget(tp,c1347977.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
		-- 登记将1张卡返回手牌的操作信息，供后续处理使用。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
	end
end
-- 效果处理时，取出登记的回卡组和回手牌对象，若与效果仍有联系，则分别将回卡组对象送去持有者卡组最上面、回手牌对象送去持有者手卡。
function c1347977.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时登记的回卡组对象组g1。
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取效果发动时登记的回手牌对象组g2。
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if g1 and g1:GetFirst():IsRelateToEffect(e) then
		-- 将回卡组对象以效果原因送回持有者卡组最上面。
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
	if g2 and g2:GetFirst():IsRelateToEffect(e) then
		-- 将回手牌对象以效果原因送回持有者手卡。
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
