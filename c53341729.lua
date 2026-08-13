--閃光を吸い込むマジック・ミラー
-- 效果：
-- 只要这张卡在场上存在，场上·墓地发动的光属性怪兽的效果无效化。
function c53341729.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上·墓地发动的光属性怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c53341729.disop)
	c:RegisterEffect(e2)
end
-- 当连锁处理时，若连锁效果为光属性怪兽效果且发动位置在场上或墓地，则使该连锁效果无效化。
function c53341729.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果发动的位置（场上或墓地），用于后续判断是否满足无效条件。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and (loc==LOCATION_MZONE or loc==LOCATION_GRAVE)
		and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT) then
		-- 将当前连锁的效果无效化，使满足条件的光属性怪兽效果发动无效。
		Duel.NegateEffect(ev)
	end
end
