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
	-- 只要这张卡在魔法与陷阱区域存在，每次怪兽的效果发动，给这张卡放置1个魔石指示物（最多2个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 在怪兽的效果发动时记录连锁发生时这张卡在魔法与陷阱区域存在，为之后放置魔石指示物做准备
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 只要这张卡在魔法与陷阱区域存在，每次怪兽的效果发动，给这张卡放置1个魔石指示物（最多2个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c67234805.ctop)
	c:RegisterEffect(e2)
	-- 只要这张卡有2个魔石指示物放置中，双方不能把场上的表侧表示怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c67234805.discon)
	c:RegisterEffect(e3)
	-- 只要这张卡有2个魔石指示物放置中，场上的表侧表示怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c67234805.discon)
	e4:SetTarget(c67234805.distg)
	c:RegisterEffect(e4)
	-- 自己·对方的结束阶段，这张卡有魔石指示物放置中的场合发动。这张卡的魔石指示物全部取除。
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
-- 连锁处理结束时，若发动的是怪兽的效果且这张卡在连锁发生时已在魔法与陷阱区域存在，则给这张卡放置1个魔石指示物
function c67234805.ctop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_MONSTER) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 判断这张卡上放置的魔石指示物数量是否为2个，作为效果无效化及不能发动的适用条件
function c67234805.discon(e)
	return e:GetHandler():GetCounter(0x16)==2
end
-- 将效果无效化的对象限定为场上的效果怪兽
function c67234805.distg(e,c)
	return c:IsType(TYPE_EFFECT)
end
-- 判断这张卡上是否放置有魔石指示物，作为结束阶段诱发必发效果的发动条件
function c67234805.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x16)>0
end
-- 将这张卡上放置的全部魔石指示物取除
function c67234805.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x16,e:GetHandler():GetCounter(0x16),REASON_EFFECT)
end
