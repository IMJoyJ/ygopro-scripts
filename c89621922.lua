--N・フレア・スカラベ
-- 效果：
-- 这张卡的攻击力上升对方场上的魔法·陷阱卡数量×400的数值。
function c89621922.initial_effect(c)
	-- 这张卡的攻击力上升对方场上的魔法·陷阱卡数量×400的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89621922,0))
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c89621922.val)
	c:RegisterEffect(e1)
end
-- 计算攻击力上升数值的辅助函数
function c89621922.val(e,c)
	-- 获取对方场上的魔法·陷阱卡数量并乘以400，作为攻击力上升的数值
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)*400
end
