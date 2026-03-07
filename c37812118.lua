--カップ・オブ・エース
-- 效果：
-- ①：进行1次投掷硬币。表的场合，自己从卡组抽2张。里的场合，对方从卡组抽2张。
function c37812118.initial_effect(c)
	-- ①：进行1次投掷硬币。表的场合，自己从卡组抽2张。里的场合，对方从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37812118.target)
	e1:SetOperation(c37812118.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c37812118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 设置操作信息为投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果作用
function c37812118.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家投掷1次硬币
	local res=Duel.TossCoin(tp,1)
	-- 硬币为正面时自己抽2张卡
	if res==1 then Duel.Draw(tp,2,REASON_EFFECT)
	-- 硬币为反面时对方抽2张卡
	else Duel.Draw(1-tp,2,REASON_EFFECT) end
end
