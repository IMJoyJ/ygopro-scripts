--能力吸収石
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次怪兽的效果发动，给这张卡放置1个魔石指示物（最多2个）。
-- ②：只要这张卡有2个魔石指示物放置中，场上的表侧表示怪兽的效果无效化，双方不能把场上的表侧表示怪兽的效果发动。
-- ③：自己·对方的结束阶段，这张卡有魔石指示物放置中的场合发动。这张卡的魔石指示物全部取除。
function c67234805.initial_effect(c)
	c:EnableCounterPermit(0x16)
	c:SetCounterLimit(0x16,2)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁注册效果：追踪本连锁中怪兽效果的发动记录
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 设置连锁注册处理函数
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次怪兽的效果发动，给这张卡放置1个魔石指示物（最多2个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c67234805.ctop)
	c:RegisterEffect(e2)
	-- 双方不能把场上的表侧表示怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c67234805.discon)
	c:RegisterEffect(e3)
	-- ②：只要这张卡有2个魔石指示物放置中，场上的表侧表示怪兽的效果无效化，双方不能把场上的表侧表示怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c67234805.discon)
	e4:SetTarget(c67234805.distg)
	c:RegisterEffect(e4)
	-- ③：自己·对方的结束阶段，这张卡有魔石指示物放置中的场合发动。这张卡的魔石指示物全部去除。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c67234805.rmcon)
	e5:SetOperation(c67234805.rmop)
	c:RegisterEffect(e5)
end
c67234805.mentioned_counter={
	[0x16]=true,
}
-- 放置指示物处理：若当前连锁成功发动了怪兽效果，给此卡放置1个魔石指示物
function c67234805.ctop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 效果无效及封锁发动条件检查：此卡上的魔石指示物数量刚好为2个
function c67234805.discon(e)
	return e:GetHandler():GetCounter(0x16)==2
end
-- 效果无效目标过滤条件：表侧表示的效果怪兽
function c67234805.distg(e,c)
	return c:IsType(TYPE_EFFECT)
end
-- 指示物去除条件检查：此卡上有至少1个魔石指示物
function c67234805.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x16)>0
end
-- 结束阶段指示物去除处理：去除此卡上所有的魔石指示物
function c67234805.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x16,e:GetHandler():GetCounter(0x16),REASON_EFFECT)
end
