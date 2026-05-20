--TGX300
-- 效果：
-- 自己场上表侧表示存在的名字带有「科技属」的怪兽每有1只，自己场上表侧表示存在的怪兽的攻击力上升300。
function c58258899.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「科技属」的怪兽每有1只，自己场上表侧表示存在的怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c58258899.val)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示且卡名含有「科技属」的怪兽
function c58258899.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
-- 计算攻击力上升数值的函数，返回符合条件的怪兽数量乘以300的值
function c58258899.val(e,c)
	-- 获取自己场上表侧表示的「科技属」怪兽数量并乘以300作为攻击力上升值
	return Duel.GetMatchingGroupCount(c58258899.filter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
