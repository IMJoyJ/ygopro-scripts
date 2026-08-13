--ジュラック・プロトプス
-- 效果：
-- 这张卡的攻击力上升对方场上存在的怪兽数量×100的数值。
function c23927545.initial_effect(c)
	-- 这张卡的攻击力上升对方场上存在的怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c23927545.val)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升数值的计算函数：根据此卡控制者的对方场上存在的怪兽数量，计算出该卡攻击力应上升的数值（每只怪兽上升100）。
function c23927545.val(e,c)
	-- 获取此卡控制者的对方场上怪兽区的怪兽数量，乘以100后作为攻击力上升值返回。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*100
end
