--聖なる守り手
-- 效果：
-- ①：这张卡反转的场合，从以下效果选择1个发动。
-- ●以场上1只表侧表示怪兽为对象发动。那只表侧表示怪兽回到持有者卡组最上面。
-- ●自己场上有战士族怪兽存在的场合，以场上2只表侧表示怪兽为对象发动。那1只表侧表示怪兽回到持有者卡组最上面。那之后，自己场上有战士族怪兽存在的场合，另1只表侧表示怪兽回到持有者手卡。
function c1347977.initial_effect(c)
	-- 创建反转效果，选择1个发动，将对象怪兽送回卡组最上面
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1347977,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c1347977.target)
	e1:SetOperation(c1347977.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择场上表侧表示的怪兽（可送回卡组）
function c1347977.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤函数：选择场上表侧表示的怪兽（可送回手牌）
function c1347977.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数：选择自己场上的战士族怪兽
function c1347977.filter3(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果处理时的选卡阶段，选择1只怪兽送回卡组最上面
function c1347977.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择场上1只表侧表示的怪兽作为送回卡组的对象
	local g1=Duel.SelectTarget(tp,c1347977.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g1:GetCount()==0 then return end
	-- 设置操作信息：将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	-- 检查自己场上有战士族怪兽存在
	if Duel.IsExistingMatchingCard(c1347977.filter3,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否存在可送回手牌的怪兽
		and Duel.IsExistingTarget(c1347977.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,g1:GetFirst())
		-- 询问玩家是否再选择1只怪兽送回手牌
		and Duel.SelectYesNo(tp,aux.Stringid(1347977,1)) then  --"是否要再选择场上的1只表侧表示的怪兽回到手卡？"
		-- 提示玩家选择要送回手牌的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		-- 选择场上1只表侧表示的怪兽作为送回手牌的对象
		local g2=Duel.SelectTarget(tp,c1347977.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
		-- 设置操作信息：将选中的怪兽送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
	end
end
-- 效果处理阶段，执行送卡操作
function c1347977.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中送回卡组的怪兽
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取操作信息中送回手牌的怪兽
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
	if g1 and g1:GetFirst():IsRelateToEffect(e) then
		-- 将怪兽送回卡组最上面
		Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
	if g2 and g2:GetFirst():IsRelateToEffect(e) then
		-- 将怪兽送回手牌
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
	end
end
