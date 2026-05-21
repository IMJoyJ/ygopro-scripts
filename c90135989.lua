--雲魔物のスコール
-- 效果：
-- 每次自己的准备阶段时给场上表侧表示存在的全部怪兽放置1个雾指示物。
function c90135989.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段时给场上表侧表示存在的全部怪兽放置1个雾指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90135989,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c90135989.condition)
	e2:SetOperation(c90135989.operation)
	c:RegisterEffect(e2)
end
-- 定义效果的发动条件函数
function c90135989.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（即自己的准备阶段）
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果的处理操作：遍历并给符合条件的怪兽放置雾指示物
function c90135989.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有可以放置雾指示物（0x1019）的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1019,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1019,1)
		tc=g:GetNext()
	end
end
