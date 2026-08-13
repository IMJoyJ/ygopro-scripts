--ブラック・マジシャン・ガール
-- 效果：
-- ①：这张卡的攻击力上升双方墓地的「黑魔术师」「黑混沌之魔术师」数量×300。
function c38033121.initial_effect(c)
	-- 调用aux.AddCodeList将卡号46986414（「黑魔术师」）登记为这张卡上记载的卡名，用于规则上识别卡面文本中包含该卡名。
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
-- 定义计算攻击力上升数值的函数：根据双方墓地中符合条件的怪兽数量来决定上升多少。
function c38033121.val(e,c)
	-- 统计以这张卡控制者视角看到的双方墓地中卡号为30208479（「黑混沌之魔术师」）或46986414（「黑魔术师」）的卡的数量，并将该数量乘以300作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,30208479,46986414)*300
end
