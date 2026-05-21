--氷結界の交霊師
-- 效果：
-- ①：对方场上的卡数量比自己场上的卡多4张以上的场合，这张卡可以从手卡特殊召唤。
-- ②：只要这张卡在自己的怪兽区域存在，那个期间对方1回合只能有1张魔法·陷阱卡发动。
function c88494899.initial_effect(c)
	-- ①：对方场上的卡数量比自己场上的卡多4张以上的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c88494899.spcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在自己的怪兽区域存在，那个期间对方1回合只能有1张魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c88494899.count)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在自己的怪兽区域存在，那个期间对方1回合只能有1张魔法·陷阱卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c88494899.rst)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在自己的怪兽区域存在，那个期间对方1回合只能有1张魔法·陷阱卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(c88494899.econ)
	e4:SetValue(c88494899.elimit)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：检查我方怪兽区是否有空位，以及对方场上的卡是否比我方多4张以上
function c88494899.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区域是否有可用的空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上的卡数量比自己场上的卡数量多4张以上
		and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>=4
end
-- 对方发动魔法·陷阱卡时，给自身注册一个持续到回合结束的标识，用于记录发动次数
function c88494899.count(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():RegisterFlagEffect(88494899,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 若对方发动的魔法·陷阱卡的发动被无效，则重置（清除）该标识，不计入发动次数
function c88494899.rst(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(88494899)
end
-- 限制发动效果的启用条件：自身存在对方本回合已发动过魔陷的标识
function c88494899.econ(e)
	return e:GetHandler():GetFlagEffect(88494899)~=0
end
-- 限制发动的类型：魔法·陷阱卡的发动
function c88494899.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
