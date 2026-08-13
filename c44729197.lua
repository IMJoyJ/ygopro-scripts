--スチームロイド
-- 效果：
-- ①：这张卡向对方怪兽攻击的伤害步骤内，攻击力上升500。这张卡被对方怪兽攻击的伤害步骤内，攻击力下降500。
function c44729197.initial_effect(c)
	-- ①：这张卡向对方怪兽攻击的伤害步骤内，攻击力上升500。这张卡被对方怪兽攻击的伤害步骤内，攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c44729197.condtion)
	e1:SetValue(c44729197.val)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前阶段为伤害步骤或伤害计算时，即仅在战斗伤害相关步骤内适用此攻击力变化效果。
function c44729197.condtion(e)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end
-- 计算攻击力变动值：若此卡为攻击者且存在攻击对象则上升500，若此卡为攻击对象则下降500，否则不改变。
function c44729197.val(e,c)
	-- 当此卡是发起攻击的怪兽且对方存在被攻击的怪兽时，攻击力上升500。
	if Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil then return 500
	-- 当此卡是对方怪兽的攻击对象时，攻击力下降500。
	elseif e:GetHandler()==Duel.GetAttackTarget() then return -500
	else return 0 end
end
