--形勢反転
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己回合内，对方场上的表侧表示怪兽的效果无效化，对方回合内，自己场上的表侧表示怪兽的效果无效化。
function c5779502.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己回合内，对方场上的表侧表示怪兽的效果无效化，对方回合内，自己场上的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c5779502.disable)
	c:RegisterEffect(e2)
end
-- 定义无效化效果的适用对象筛选函数
function c5779502.disable(e,c)
	-- 判断目标卡片是否为效果怪兽（或原本是效果怪兽），且其控制者为当前非回合玩家（即自己回合的对方怪兽，或对方回合的自己怪兽）
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and c:IsControler(1-Duel.GetTurnPlayer())
end
