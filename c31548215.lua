--墓穴ホール
-- 效果：
-- ①：手卡·墓地的怪兽或者除外中的怪兽的效果由对方发动时才能发动。那个效果无效，给与对方2000伤害。
function c31548215.initial_effect(c)
	-- 效果原文内容：①：手卡·墓地的怪兽或者除外中的怪兽的效果由对方发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c31548215.condition)
	e1:SetTarget(c31548215.target)
	e1:SetOperation(c31548215.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断连锁是否满足发动条件，包括对方发动、效果可无效、为怪兽卡、且在手卡、墓地或除外区
function c31548215.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 效果作用：判断发动玩家为对方、连锁效果可无效、发动效果为怪兽类型、且发动位置在手卡、墓地或除外区
	return ep==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and (LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)&loc~=0
end
-- 效果原文内容：那个效果无效，给与对方2000伤害。
function c31548215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 效果作用：设置连锁操作信息为对对方造成2000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 效果作用：执行效果，使连锁效果无效并造成对方2000伤害
function c31548215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：尝试使当前连锁效果无效
	if Duel.NegateEffect(ev) then
		-- 效果作用：对对方造成2000伤害
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
