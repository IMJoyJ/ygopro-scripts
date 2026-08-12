--底なし流砂
-- 效果：
-- 对方的回合结束时，全场的最高攻击力的表侧表示的怪兽破坏。自己的准备阶段时，自己的手卡4张以下的场合，这张卡破坏。
function c76532077.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 对方的回合结束时，全场的最高攻击力的表侧表示的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76532077,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c76532077.descon)
	e2:SetTarget(c76532077.destg)
	e2:SetOperation(c76532077.desop)
	c:RegisterEffect(e2)
	-- 自己的准备阶段时，自己的手卡4张以下的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c76532077.descon2)
	c:RegisterEffect(e3)
end
-- 定义回合结束时破坏效果的发动条件函数
function c76532077.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 定义破坏效果的发动检测与目标确认函数
function c76532077.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		-- 设置效果处理信息，将攻击力最高的怪兽作为破坏对象
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,tg:GetCount(),0,0)
	end
end
-- 定义破坏效果的实际执行函数
function c76532077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		-- 将攻击力最高的怪兽破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 定义自身自我破坏效果的条件函数
function c76532077.descon2(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前是否为自己的准备阶段，且自己的手卡数量在4张以下
	return tp==Duel.GetTurnPlayer() and Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<=4
end
