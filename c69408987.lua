--スパイダー・ウェブ
-- 效果：
-- 怪兽攻击宣言的场合，那只怪兽在伤害步骤结束时变成守备表示，直到从那只怪兽的控制者来看的下次的自己回合的结束阶段时不能把表示形式改变。
function c69408987.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 怪兽攻击宣言的场合，那只怪兽在伤害步骤结束时变成守备表示，直到从那只怪兽的控制者来看的下次的自己回合的结束阶段时不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c69408987.poscon)
	e2:SetOperation(c69408987.posop)
	c:RegisterEffect(e2)
end
-- 检查发动条件：攻击怪兽是否处于表侧攻击表示，且在伤害步骤结束时仍与战斗相关联。
function c69408987.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽。
	local a=Duel.GetAttacker()
	return a:IsPosition(POS_FACEUP_ATTACK) and a:IsRelateToBattle()
end
-- 执行效果：将攻击怪兽变为表侧守备表示，并注册不能改变表示形式的效果。
function c69408987.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 若成功将攻击怪兽变为表侧守备表示。
	if Duel.ChangePosition(a,POS_FACEUP_DEFENSE)~=0 then
		e:GetHandler():CreateRelation(a,RESET_EVENT+RESETS_STANDARD)
		-- 直到从那只怪兽的控制者来看的下次的自己回合的结束阶段时不能把表示形式改变。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
		e1:SetCondition(c69408987.poscon2)
		a:RegisterEffect(e1)
	end
end
-- 检查作为效果来源的「蜘蛛网」是否仍与该怪兽存在联系（即「蜘蛛网」是否仍在场上）。
function c69408987.poscon2(e)
	return e:GetOwner():IsRelateToCard(e:GetHandler())
end
