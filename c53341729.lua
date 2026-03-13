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
-- 连锁处理时判定发动者是否为场上·墓地的光属性怪兽，满足条件则无效该连锁效果。
function c53341729.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁发动的位置信息（如怪兽区或墓地）。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and (loc==LOCATION_MZONE or loc==LOCATION_GRAVE)
		and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT) then
		-- 无效化当前连锁发动的效果。
		Duel.NegateEffect(ev)
	end
end
