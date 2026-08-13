--パーフェクト機械王
-- 效果：
-- 场上存在的这张卡以外的机械族怪兽每有1只，这张卡的攻击力上升500。
function c18891691.initial_effect(c)
	-- 场上存在的这张卡以外的机械族怪兽每有1只，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c18891691.val)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升值的计算函数：统计双方场上除自身以外的表侧表示机械族怪兽数量，每1只使攻击力上升500。
function c18891691.val(e,c)
	-- 用Duel.GetMatchingGroupCount统计双方场上满足机械族表侧表示条件的怪兽数量（已排除e:GetHandler()即这张卡自身），数量乘以500作为攻击力上升值。
	return Duel.GetMatchingGroupCount(c18891691.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*500
end
-- 过滤条件：卡须为表侧表示且种族为机械族。
function c18891691.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
