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
-- 定义攻击力上升值的计算函数：根据这张卡的控制者墓地中存在的「幻灵草」数量，每有1张攻击力上升500点。
function c41249545.atkup(e,c)
	-- 统计这张卡的控制者墓地中卡名为「幻灵草」的卡片数量，并将该数量乘以500作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,nil,41249545)*500
end
