--地縛波
-- 效果：
-- 自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方的魔法·陷阱卡的发动无效并破坏。
function c29934351.initial_effect(c)
	-- 自己场上有名字带有「地缚神」的怪兽表侧表示存在的场合才能发动。对方的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29934351.condition)
	e1:SetTarget(c29934351.target)
	e1:SetOperation(c29934351.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否为表侧表示且字段为「地缚神」（0x1021）。
function c29934351.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1021)
end
-- 发动条件：对方发动魔法·陷阱卡且该连锁可以无效，并且自己场上有表侧表示「地缚神」怪兽存在。
function c29934351.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方是连锁发动者、该效果为魔法·陷阱卡的发动手法（EFFECT_TYPE_ACTIVATE），且该连锁的发动可以被无效。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己主要怪兽区存在至少1张表侧表示的「地缚神」怪兽。
		and Duel.IsExistingMatchingCard(c29934351.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的目标处理：设定本连锁的操作信息；若对方发动的卡可被破坏且仍与效果关联，则追加破坏目标信息。
function c29934351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将连锁中的卡片（eg）标记为无效对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将连锁中的卡片（eg）标记为破坏对象，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使对方的魔法·陷阱卡发动无效，并在成功后将其破坏。
function c29934351.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该连锁是否被成功无效，且原发动卡仍与效果保持关联（未被移离等）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将被无效的那张魔法·陷阱卡以效果原因破坏送入墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
