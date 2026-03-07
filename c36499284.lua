--炎舞－「揺光」
-- 效果：
-- 这张卡的发动时可以选择对方场上表侧表示存在的1张卡。那个场合，从自己手卡丢弃1只兽战士族怪兽，选择的卡破坏。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
function c36499284.initial_effect(c)
	-- 效果原文：这张卡的发动时可以选择对方场上表侧表示存在的1张卡。那个场合，从自己手卡丢弃1只兽战士族怪兽，选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36499284.target)
	e1:SetOperation(c36499284.activate)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为种族为兽战士族的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e2:SetValue(100)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断目标怪兽是否表侧表示
function c36499284.filter(c)
	return c:IsFaceup()
end
-- 过滤函数，判断手卡中是否包含可丢弃的兽战士族怪兽
function c36499284.filter2(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsDiscardable()
end
-- 处理效果的发动阶段，判断是否满足发动条件并选择目标
function c36499284.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c36499284.filter(chkc) end
	if chk==0 then return true end
	-- 检查对方场上是否存在满足条件的怪兽
	if Duel.IsExistingTarget(c36499284.filter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己手卡中是否存在满足条件的兽战士族怪兽
		and Duel.IsExistingMatchingCard(c36499284.filter2,tp,LOCATION_HAND,0,1,nil)
		-- 询问玩家是否发动效果
		and Duel.SelectYesNo(tp,aux.Stringid(36499284,0)) then  --"是否要选择对方场上表侧表示存在的1张卡破坏？"
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的一张卡作为破坏对象
		local g=Duel.SelectTarget(tp,c36499284.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置连锁操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetProperty(0)
	end
end
-- 处理效果的发动，执行破坏操作
function c36499284.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	-- 丢弃一张兽战士族怪兽并确认目标怪兽有效且表侧表示
	if Duel.DiscardHand(tp,c36499284.filter2,1,1,REASON_EFFECT+REASON_DISCARD)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
