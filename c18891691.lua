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
-- 计算满足条件的机械族怪兽数量并乘以500作为攻击力加成
function c18891691.val(e,c)
	-- 检索满足过滤条件的机械族怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(c18891691.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*500
end
-- 过滤条件：怪兽必须是表侧表示且属于机械族
function c18891691.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
