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
-- 返回对方场上怪兽数量乘以100的数值
function c23927545.val(e,c)
	-- 检索对方场上怪兽数量并乘以100
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*100
end
