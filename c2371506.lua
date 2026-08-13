--エクシーズ・リフレクト
-- 效果：
-- 场上的超量怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。那之后，给与对方基本分800分伤害。
function c2371506.initial_effect(c)
	-- 场上的超量怪兽为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。那之后，给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c2371506.condition)
	e1:SetTarget(c2371506.target)
	e1:SetOperation(c2371506.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断卡是否为场上表侧表示的超量怪兽（位于怪兽区域、表侧表示、超量类型），用于检查连锁对象中是否存在符合本卡条件的超量怪兽。
function c2371506.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 发动条件判定：仅在对方发动取对象效果（且为效果怪兽的效果或魔法·陷阱卡的发动），该效果对象中包含场上的表侧表示超量怪兽，并且该发动可以被无效时，本卡才能发动。
function c2371506.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁（被连锁的效果）所取的对象卡片组，用于检查其中是否有超量怪兽。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回真条件：对象卡片组存在且其中至少有1张场上表侧表示的超量怪兽，且该连锁发动可被无效。
	return tg and tg:IsExists(c2371506.cfilter,1,nil) and Duel.IsChainNegatable(ev)
end
-- 发动时处理：确认发动合法，并登记操作信息——无效并破坏当前发动的效果卡，同时给与对方800伤害；其中破坏的登记需判断该卡可破坏且仍然关联。
function c2371506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前发动的卡（eg）登记为无效对象，数量1，用于无效发动的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将当前发动的卡（eg）登记为破坏对象，数量1，用于破坏效果检测。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：登记给与对方玩家800点效果伤害，目标玩家为对方（1-tp），不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理：实际执行本卡的连锁——先无效对方发动，成功且关联时将其破坏，随后单独给与对方800伤害。
function c2371506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前连锁的发动，并确认要破坏的那张卡仍与该效果关联（没有因故离场），若都满足才进行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏被无效的那张发动卡（eg），将其送去墓地。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 中断当前效果处理流程，使后续的伤害处理与之前的无效/破坏处理视为不同时处理，以避免错过时点。
	Duel.BreakEffect()
	-- 给与对方玩家800点效果伤害（对方为1-tp）。
	Duel.Damage(1-tp,800,REASON_EFFECT)
end
