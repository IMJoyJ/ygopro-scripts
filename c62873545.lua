--究極竜騎士
-- 效果：
-- 「混沌战士」＋「青眼究极龙」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升自己场上的其他的龙族怪兽数量×500。
function c62873545.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加以「混沌战士」和「青眼究极龙」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,5405694,23995346,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升自己场上的其他的龙族怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c62873545.atkval)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的龙族怪兽的条件函数
function c62873545.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 计算攻击力上升数值的函数，返回自己场上除自身以外的龙族怪兽数量×500的值
function c62873545.atkval(e,c)
	-- 获取自己场上除这张卡以外的表侧表示龙族怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(c62873545.filter,c:GetControler(),LOCATION_MZONE,0,c)*500
end
