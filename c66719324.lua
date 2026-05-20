--恵みの雨
-- 效果：
-- 双方的基本分回复1000分。
function c66719324.initial_effect(c)
	-- 双方的基本分回复1000分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c66719324.target)
	e1:SetOperation(c66719324.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标检查与操作信息设置函数
function c66719324.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果包含双方玩家回复1000基本分的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,1000)
end
-- 定义效果运行的具体处理函数
function c66719324.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使回合玩家（自身）回复1000基本分
	Duel.Recover(tp,1000,REASON_EFFECT)
	-- 使对手玩家回复1000基本分
	Duel.Recover(1-tp,1000,REASON_EFFECT)
end
