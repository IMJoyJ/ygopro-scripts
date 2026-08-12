--アタック・フェロモン
-- 效果：
-- 自己场上存在的爬虫类族怪兽向守备表示怪兽攻击的场合，那只怪兽在伤害步骤结束时变成表侧攻击表示。
function c68786330.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上存在的爬虫类族怪兽向守备表示怪兽攻击的场合，那只怪兽在伤害步骤结束时变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68786330,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c68786330.poscon)
	e2:SetOperation(c68786330.posop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：攻击怪兽与被攻击怪兽均未离场，且攻击怪兽是爬虫类族、被攻击怪兽是守备表示怪兽
function c68786330.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取作为攻击目标的怪兽
	local d=Duel.GetAttackTarget()
	return a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:IsRace(RACE_REPTILE) and d:IsDefensePos()
end
-- 将作为攻击目标的怪兽改变为表侧攻击表示
function c68786330.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为攻击目标的怪兽
	local a=Duel.GetAttackTarget()
	-- 将目标怪兽改变为表侧攻击表示
	Duel.ChangePosition(a,POS_FACEUP_ATTACK)
end
