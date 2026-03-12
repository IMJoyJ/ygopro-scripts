--暗黒ヴェロキ
-- 效果：
-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升400。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降400。
function c52319752.initial_effect(c)
	-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升 400。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降 400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c52319752.condtion)
	e1:SetValue(c52319752.val)
	c:RegisterEffect(e1)
end
-- 判断当前阶段是否为伤害步骤或伤害计算时，以确定效果是否适用
function c52319752.condtion(e)
	-- 获取决斗当前的阶段编号
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end
-- 根据攻击状态计算攻击力增减数值，返回 400、-400 或 0
function c52319752.val(e,c)
	-- 当自身为攻击怪兽且存在攻击对象时，返回攻击力上升值
	if Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil then return 400
	-- 当自身为被攻击怪兽时，返回攻击力下降值
	elseif e:GetHandler()==Duel.GetAttackTarget() then return -400
	else return 0 end
end
