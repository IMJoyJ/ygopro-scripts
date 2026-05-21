--E・HERO ザ・ヒート
-- 效果：
-- ①：这张卡的攻击力上升自己场上的「元素英雄」怪兽数量×200。
function c98266377.initial_effect(c)
	-- ①：这张卡的攻击力上升自己场上的「元素英雄」怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c98266377.val)
	c:RegisterEffect(e1)
end
-- 过滤表侧表示的「元素英雄」怪兽
function c98266377.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 计算攻击力上升数值的辅助函数
function c98266377.val(e,c)
	-- 返回自己场上表侧表示的「元素英雄」怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(c98266377.filter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end
