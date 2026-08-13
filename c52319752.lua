--暗黒ヴェロキ
-- 效果：
-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升400。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降400。
function c52319752.initial_effect(c)
	-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升400。这张卡被对方怪兽攻击的场合，伤害步骤内攻击力下降400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c52319752.condtion)
	e1:SetValue(c52319752.val)
	c:RegisterEffect(e1)
end
-- 该效果的条件函数：仅在当前阶段为伤害步骤或伤害计算时，允许攻击力变化效果生效。
function c52319752.condtion(e)
	-- 获取当前游戏阶段，并存入局部变量ph中，用于后续判断是否为伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end
-- 该效果的值计算函数：根据本卡在战斗中的身份（攻击怪兽或攻击目标）计算攻击力增减数值，分别对应攻击对方怪兽时上升400、被对方怪兽攻击时下降400，其他情况不增减。
function c52319752.val(e,c)
	-- 若当前攻击怪兽是本卡且存在攻击目标（即本卡向对方怪兽发动攻击），则攻击力上升400。
	if Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil then return 400
	-- 否则，若本卡是当前的攻击目标（即本卡被对方怪兽攻击），则攻击力下降400。
	elseif e:GetHandler()==Duel.GetAttackTarget() then return -400
	else return 0 end
end
