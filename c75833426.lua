--マドルチェ・ティーブレイク
-- 效果：
-- 自己墓地没有怪兽存在的场合才能发动。魔法·陷阱卡的发动无效，那张卡回到持有者手卡。自己场上有「魔偶甜点·布丁公主」存在的场合，可以再选对方场上1张卡破坏。
function c75833426.initial_effect(c)
	-- 自己墓地没有怪兽存在的场合才能发动。魔法·陷阱卡的发动无效，那张卡回到持有者手卡。自己场上有「魔偶甜点·布丁公主」存在的场合，可以再选对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c75833426.condition)
	e1:SetTarget(c75833426.target)
	e1:SetOperation(c75833426.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自己墓地没有怪兽，且连锁中的发动是魔法·陷阱卡的发动，并且该发动可以被无效
function c75833426.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在怪兽卡（必须不存在怪兽卡）
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
		-- 检查被连锁的效果是否为魔法·陷阱卡的发动，且该发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：场上表侧表示的「魔偶甜点·布丁公主」
function c75833426.cfilter(c)
	return c:IsFaceup() and c:IsCode(74641045)
end
-- 效果发动时的处理：设置无效发动和回手牌的操作信息
function c75833426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将该卡送回持有者手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,1,0,0)
	end
end
-- 效果处理：无效发动并回手，若满足条件则可以再破坏对方场上1张卡
function c75833426.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	-- 如果成功无效该发动，且该卡在连锁处理时仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		ec:CancelToGrave()
		-- 将该卡送回持有者的手卡
		Duel.SendtoHand(ec,nil,REASON_EFFECT)
	end
	-- 检查自己场上是否存在表侧表示的「魔偶甜点·布丁公主」
	if Duel.IsExistingMatchingCard(c75833426.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在卡片
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择发动追加的破坏效果
		and Duel.SelectYesNo(tp,aux.Stringid(75833426,0)) then  --"是否要选择对方场上一张卡破坏？"
		-- 中断当前效果处理，使后续的破坏处理与前面的回手处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上的1张卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 给选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 因效果破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
