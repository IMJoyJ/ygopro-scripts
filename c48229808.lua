--ホルスの黒炎竜 LV8
-- 效果：
-- 这张卡不能通常召唤。只能通过「荷鲁斯之黑炎龙 LV6」的效果特殊召唤。只要这张卡在自己场上表侧表示存在，可以把魔法的发动和效果无效并且破坏。
function c48229808.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。只能通过「荷鲁斯之黑炎龙 LV6」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为 false，使这张卡不能被普通效果特殊召唤，只能通过指定的方式（如「荷鲁斯之黑炎龙 LV6」的效果）特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，可以把魔法的发动和效果无效并且破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48229808,0))  --"魔法发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c48229808.condition)
	e2:SetTarget(c48229808.target)
	e2:SetOperation(c48229808.operation)
	c:RegisterEffect(e2)
end
c48229808.lvup={11224103}
c48229808.lvdn={75830094,11224103}
-- 发动条件：此卡不在战斗破坏确定状态；对方连锁的是卡片发动（EFFECT_TYPE_ACTIVATE）且为魔法卡；该连锁可以被无效。
function c48229808.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 进一步要求连锁中的效果是魔法卡（TYPE_SPELL），且该魔法发动的连锁可以被无效（Duel.IsChainNegatable）。
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 发动时的检查与处理设定：chk==0 时直接允许发动；随后登记无效发动的操作信息，并根据对象魔法卡是否可破坏且仍与效果关联，登记破坏的操作信息。
function c48229808.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将本次效果处理确定为无效魔法卡的发动（CATEGORY_NEGATE），对象为当前连锁中的魔法卡（eg），数量为 1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：当对方发动的那张魔法卡可被破坏且仍与其效果关联时，追加登记破坏该卡（CATEGORY_DESTROY）的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先取得此卡自身；若此卡已里侧表示或不再与其效果关联则直接结束；否则尝试无效该魔法卡的发动，若无效成功且该魔法卡仍与其效果关联，则将其破坏。
function c48229808.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断条件：魔法卡的发动已被成功无效（NegateActivation 返回真），且该魔法卡仍与连锁效果相关，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）破坏被无效的魔法卡，完成‘无效并且破坏’中的破坏部分。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
