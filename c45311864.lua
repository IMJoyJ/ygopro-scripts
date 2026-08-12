--盗人ゴブリン
-- 效果：
-- ①：给与对方500伤害。自己回复500基本分。
function c45311864.initial_effect(c)
	-- ①：给与对方500伤害。自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45311864.target)
	e1:SetOperation(c45311864.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时设置操作信息，确定将要进行的回复和伤害效果
function c45311864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要对自身玩家回复500基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	-- 设置将要对对方玩家造成500伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果发动时执行的处理函数，对对方造成伤害并回复自身基本分
function c45311864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方玩家造成500点伤害，伤害过程分解处理
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 对自己玩家回复500基本分，回复过程分解处理
	Duel.Recover(tp,500,REASON_EFFECT,true)
	-- 完成伤害/回复LP过程的时点触发
	Duel.RDComplete()
end
