--機械王－プロトタイプ
-- 效果：
-- 场上存在的这张卡以外的机械族怪兽每有1只，这张卡的攻击力·守备力上升100。
function c89222931.initial_effect(c)
	-- 场上存在的这张卡以外的机械族怪兽每有1只，这张卡的攻击力上升100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c89222931.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 计算并返回攻击力与守备力上升的数值
function c89222931.val(e,c)
	-- 获取双方场上除自身以外满足过滤条件的怪兽数量并乘以100
	return Duel.GetMatchingGroupCount(c89222931.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*100
end
-- 过滤条件：表侧表示且是机械族的怪兽
function c89222931.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
