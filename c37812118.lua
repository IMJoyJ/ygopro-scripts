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
-- 效果发动时的条件判定与操作信息设置：确认双方玩家均能抽卡，并设置本次连锁将进行1次投掷硬币的操作信息。
function c37812118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：若处于条件确认阶段，则判定双方玩家是否都能抽2张卡（因为硬币结果可能使任一玩家抽卡），双方都能时才允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 设置连锁操作信息：将本连锁的效果类别标记为硬币效果，由发动玩家进行1次投掷硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理时执行：投掷1次硬币，根据正反结果决定由谁抽2张卡并执行抽卡。
function c37812118.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动玩家投掷1枚硬币，返回结果存入res（1为正面，0为反面）。
	local res=Duel.TossCoin(tp,1)
	-- 若硬币结果为正面，则发动玩家自己抽2张卡，抽卡原因为效果。
	if res==1 then Duel.Draw(tp,2,REASON_EFFECT)
	-- 若硬币结果为反面，则对方玩家抽2张卡，抽卡原因为效果。
	else Duel.Draw(1-tp,2,REASON_EFFECT) end
end
