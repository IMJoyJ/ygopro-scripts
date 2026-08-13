--墓穴ホール
-- 效果：
-- ①：手卡·墓地的怪兽或者除外中的怪兽的效果由对方发动时才能发动。那个效果无效，给与对方2000伤害。
function c31548215.initial_effect(c)
	-- ①：手卡·墓地的怪兽或者除外中的怪兽的效果由对方发动时才能发动。那个效果无效，给与对方2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c31548215.condition)
	e1:SetTarget(c31548215.target)
	e1:SetOperation(c31548215.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：对方发动了效果，且该效果为怪兽效果、发动位置在手卡·墓地·除外区之一、且该连锁效果可以被无效时，本卡才能发动。
function c31548215.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（对方发动的效果）的发生位置，用于判断是否来自手卡·墓地或除外区。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判定全部发动条件：发动者为对方、该效果可被无效、是怪兽效果、且效果发动位置在手卡·墓地或除外区的区域内。
	return ep==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and (LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)&loc~=0
end
-- 发动时处理：检查发动合法性（chk==0时直接允许），并设置“无效效果”和“造成伤害”的操作信息，供后续检测与处理使用。
function c31548215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的卡片（eg）标记为要被无效的对象，数量为1，分类为无效效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：确定将对对方玩家造成2000点伤害，伤害分类为伤害效果，目标玩家为对方。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 效果处理：先尝试无效对方发动的那个连锁效果，若无效成功，则给对方造成2000点伤害。
function c31548215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前连锁（对方发动的效果），返回是否成功无效。
	if Duel.NegateEffect(ev) then
		-- 如果无效成功，则给予对方玩家2000点效果伤害。
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
