--グラスファントム
-- 效果：
-- 这张卡的攻击力上升自己墓地存在的「幻灵草」的数量×500的数值。
function c41249545.initial_effect(c)
	-- 这张卡的攻击力上升自己墓地存在的「幻灵草」的数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c41249545.atkup)
	c:RegisterEffect(e1)
end
-- 检索自己墓地里编号为41249545的卡片数量并乘以500作为攻击力上升值
function c41249545.atkup(e,c)
	-- 返回自己墓地里编号为41249545的卡片数量乘以500的结果
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,41249545)*500
end
