--竜魔王ベクターP
-- 效果：
-- ←3 【灵摆】 3→
-- ①：只要这张卡在灵摆区域存在，对方的灵摆区域的卡的效果无效化。
-- 【怪兽描述】
-- 统率着突然出现在这个世上并转眼就彻底蹂躏了世界的大群龙魔族的魔王。据说他是以“龙化秘法”转变了万物成为邪恶的龙形，不过那种力量的真面目还不怎么清楚。强大魔力的源泉甚至有传闻说是不属于这个次元的。
function c69512157.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，对方的灵摆区域的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_PZONE)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在灵摆区域存在，对方的灵摆区域的卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_PZONE)
	e3:SetOperation(c69512157.disop)
	c:RegisterEffect(e3)
end
-- 在连锁处理时，若触发的效果是对方灵摆区域的灵摆卡效果，则将其无效
function c69512157.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理中的连锁的控制者以及连锁发生的位置
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	if re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL and p~=tp and bit.band(loc,LOCATION_PZONE)~=0 then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
