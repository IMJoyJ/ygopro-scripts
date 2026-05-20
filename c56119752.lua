--プレゼントカード
-- 效果：
-- 「礼物卡」在1回合只能发动1张。
-- ①：对方把手卡全部丢弃。那之后，对方从卡组抽5张。
function c56119752.initial_effect(c)
	-- 「礼物卡」在1回合只能发动1张。①：对方把手卡全部丢弃。那之后，对方从卡组抽5张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56119752+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c56119752.target)
	e1:SetOperation(c56119752.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与合法性检测函数
function c56119752.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手牌的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 在发动检测时，确认对方手牌数量大于0且对方可以进行抽5张卡的操作
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(1-tp,5) end
	-- 设置操作信息，表示该效果包含对方丢弃手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,ct)
	-- 设置操作信息，表示该效果包含对方抽5张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,5)
end
-- 效果处理的执行函数
function c56119752.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 将对方手牌全部以效果丢弃的方式送去墓地，并确认是否有卡片成功送墓
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 中断效果处理，使前后的丢弃手牌与抽卡不视为同时处理
		Duel.BreakEffect()
		-- 让对方从卡组抽5张卡
		Duel.Draw(1-tp,5,REASON_EFFECT)
	end
end
