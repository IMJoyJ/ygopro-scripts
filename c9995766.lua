--宮廷のしきたり
-- 效果：
-- ①：「宫廷的规矩」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，「宫廷的规矩」以外的双方场上的表侧表示的永续陷阱卡不会被战斗·效果破坏。
function c9995766.initial_effect(c)
	c:SetUniqueOnField(1,0,9995766)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，「宫廷的规矩」以外的双方场上的表侧表示的永续陷阱卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(c9995766.infilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断目标卡类型是否为永续陷阱（类型掩码0x20004，即永续陷阱），且卡号不是「宫廷的规矩」（9995766）。满足条件的卡才能享受该效果的保护。
function c9995766.infilter(e,c)
	return bit.band(c:GetType(),0x20004)==0x20004 and not c:IsCode(9995766)
end
