--ブラック・マジシャン・ガール
-- 效果：
-- ①：这张卡的攻击力上升双方墓地的「黑魔术师」「黑混沌之魔术师」数量×300。
function c38033121.initial_effect(c)
	-- 记录该卡具有「黑混沌之魔术师」这张卡的卡片密码
	aux.AddCodeList(c,46986414)
	-- ①：这张卡的攻击力上升双方墓地的「黑魔术师」「黑混沌之魔术师」数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c38033121.val)
	c:RegisterEffect(e1)
end
-- 定义用于计算攻击力上升值的函数
function c38033121.val(e,c)
	-- 检索双方墓地中「黑魔术师」「黑混沌之魔术师」的数量并乘以300作为攻击力上升值
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,30208479,46986414)*300
end
