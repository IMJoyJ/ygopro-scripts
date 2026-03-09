--ターボ・ウォリアー
-- 效果：
-- 「涡轮同调士」＋调整以外的怪兽1只以上
-- 6星以上的同调怪兽为攻击对象的这张卡的攻击宣言时，攻击对象怪兽的攻击力直到伤害步骤结束时变成一半。场上的这张卡不会成为6星以下的效果怪兽的效果的对象。
function c46195773.initial_effect(c)
	-- 为怪兽添加允许使用的素材卡牌代码列表，此处指定为67270095（涡轮同调士）
	aux.AddMaterialCodeList(c,67270095)
	-- 设置该怪兽的同调召唤手续，要求1只满足tfilter条件的调整和1只满足aux.NonTuner条件的非调整怪兽作为素材
	aux.AddSynchroProcedure(c,c46195773.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 攻击对象怪兽的攻击力直到伤害步骤结束时变成一半
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46195773,0))  --"攻击对象攻击变成一半"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c46195773.atktg)
	e1:SetOperation(c46195773.atkop)
	c:RegisterEffect(e1)
	-- 场上的这张卡不会成为6星以下的效果怪兽的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c46195773.efilter)
	c:RegisterEffect(e2)
end
c46195773.material_setcode=0x1017
-- 过滤函数，判断是否为涡轮同调士或具有特定效果（20932152）的怪兽
function c46195773.tfilter(c)
	return c:IsCode(67270095) or c:IsHasEffect(20932152)
end
-- 效果过滤器，判断效果来源怪兽等级是否为6以下
function c46195773.efilter(e,re,rp)
	return re:GetHandler():IsLevelBelow(6)
end
-- 设置攻击宣言时的效果目标，检查攻击对象是否为6星以上且为同调怪兽
function c46195773.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsFaceup() and d:IsLevelAbove(6) and d:IsType(TYPE_SYNCHRO) end
	d:CreateEffectRelation(e)
	-- 设置连锁操作信息，指定将攻击对象怪兽变为里侧表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
-- 执行攻击宣言时的效果操作，将攻击对象怪兽的攻击力减半
function c46195773.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击对象怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToEffect(e) then
		-- 将攻击对象怪兽的攻击力设置为原来的一半，并在伤害步骤结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(d:GetAttack()/2))
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e1)
	end
end
