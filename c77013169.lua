--超重武者ソード－999
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：自己场上的「超重武者」怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽的攻击力·守备力变成0。
function c77013169.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77013169,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c77013169.postg)
	e1:SetOperation(c77013169.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上的「超重武者」怪兽和对方怪兽进行战斗的伤害计算后发动。那只对方怪兽的攻击力·守备力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77013169,1))  --"攻守变化"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetCondition(c77013169.atkcon)
	e3:SetOperation(c77013169.atkop)
	c:RegisterEffect(e3)
end
-- 改变表示形式效果的Target函数，确认发动并设置操作信息
function c77013169.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身（1张卡）改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 改变表示形式效果的Operation函数，若自身在场则改变其表示形式
function c77013169.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身改变表示形式（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 伤害计算后效果的Condition函数，判断是否为自己场上的「超重武者」怪兽与对方怪兽进行战斗，并记录对方怪兽
function c77013169.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(d)
	return a and d and a:IsFaceup() and a:IsSetCard(0x9a) and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
-- 伤害计算后效果的Operation函数，将进行战斗的对方怪兽的攻击力·守备力变成0
function c77013169.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力·守备力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end
