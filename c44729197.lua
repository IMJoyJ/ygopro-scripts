--スチームロイド
-- 效果：
-- ①：这张卡向对方怪兽攻击的伤害步骤内，攻击力上升500。这张卡被对方怪兽攻击的伤害步骤内，攻击力下降500。
function c44729197.initial_effect(c)
	-- 效果原文内容：①：这张卡向对方怪兽攻击的伤害步骤内，攻击力上升500。这张卡被对方怪兽攻击的伤害步骤内，攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c44729197.condtion)
	e1:SetValue(c44729197.val)
	c:RegisterEffect(e1)
end
-- 判断当前是否处于伤害步骤或伤害计算时
function c44729197.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end
-- 根据攻击者和被攻击者判断攻击力变化值
function c44729197.val(e,c)
	-- 当此卡为攻击者且存在攻击目标时，攻击力上升500
	if Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil then return 500
	-- 当此卡为攻击目标时，攻击力下降500
	elseif e:GetHandler()==Duel.GetAttackTarget() then return -500
	else return 0 end
end
