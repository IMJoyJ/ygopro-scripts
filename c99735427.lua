--暗闇を吸い込むマジック・ミラー
-- 效果：
-- 只要这张卡在场上存在，场上·墓地发动的暗属性怪兽的效果无效化。
function c99735427.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上·墓地发动的暗属性怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c99735427.disop)
	c:RegisterEffect(e2)
end
-- 该函数是永续效果的发动处理操作：在连锁处理时判定发动效果的怪兽是否为暗属性且发动位置在场上或墓地，若是则使该效果无效化。
function c99735427.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁效果的发动位置，用于判断是否符合“场上·墓地发动”的条件。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and (loc==LOCATION_MZONE or loc==LOCATION_GRAVE)
		and re:GetHandler():IsAttribute(ATTRIBUTE_DARK) then
		-- 将当前连锁的暗属性怪兽效果无效化。
		Duel.NegateEffect(ev)
	end
end
