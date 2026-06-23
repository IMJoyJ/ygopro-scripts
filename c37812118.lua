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
-- 目标函数：检查双方玩家是否都能从卡组抽2张卡，并设置硬币投掷的操作信息
function c37812118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：确认双方玩家都可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 设置操作信息：标记此效果将进行一次硬币投掷（CATEGORY_COIN）
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 操作函数：执行硬币投掷并根据结果处理抽卡效果
function c37812118.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动者投掷1次硬币，获取结果（1为表，0为里）
	local res=Duel.TossCoin(tp,1)
	-- 若硬币结果为表（1），则发动者从卡组抽2张卡
	if res==1 then Duel.Draw(tp,2,REASON_EFFECT)
	-- 若硬币结果为里（0），则对方玩家从卡组抽2张卡
	else Duel.Draw(1-tp,2,REASON_EFFECT) end
end
