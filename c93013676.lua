--マハー・ヴァイロ
-- 效果：
-- ①：这张卡的攻击力上升这张卡装备的装备卡数量×500。
function c93013676.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡装备的装备卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c93013676.val)
	c:RegisterEffect(e1)
end
-- 返回该怪兽当前装备的卡片数量乘以500的数值，作为攻击力上升的幅度和依据
function c93013676.val(e,c)
	return c:GetEquipCount()*500
end
