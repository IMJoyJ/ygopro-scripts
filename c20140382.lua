--オーバーウェルム
-- 效果：
-- 自己场上有7星以上的上级召唤的怪兽表侧表示存在的场合才能发动。陷阱卡或者效果怪兽的效果的发动无效并破坏。
function c20140382.initial_effect(c)
	-- 自己场上有7星以上的上级召唤的怪兽表侧表示存在的场合才能发动。陷阱卡或者效果怪兽的效果的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20140382.condition)
	e1:SetTarget(c20140382.target)
	e1:SetOperation(c20140382.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否为表侧表示、等级7以上且通过上级召唤出场，用于筛选场上符合发动条件的我方怪兽。
function c20140382.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动条件判定：自己场上存在表侧表示的7星以上上级召唤怪兽，且当前连锁的发动可以被无效，同时被连锁的效果属于效果怪兽效果或陷阱卡的发动。
function c20140382.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件（表侧表示、7星以上、上级召唤）的怪兽。
	return Duel.IsExistingMatchingCard(c20140382.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前连锁的发动是否能够被无效，即该效果是否具备被无效的可能性。
		and Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or (re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
-- 发动时目标处理：本效果不取对象，仅将当前连锁的发动卡记为无效对象，并在其可被破坏且与发动效果保持关联时，追加标记为破坏对象。
function c20140382.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含无效效果，目标为当前连锁的发动卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：本次处理包含破坏效果，目标为当前连锁的发动卡（eg），数量为1，此时该卡必须能被破坏且与引发连锁的效果保持关联。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效当前连锁的发动，若成功且发动卡仍与那个效果保持关联，则将其破坏。
function c20140382.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了当前连锁的发动，同时确认该发动卡仍与引发连锁的效果存在关联（未离场或失去联系）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将当前连锁的发动卡（eg）以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
