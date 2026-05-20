--手札抹殺
-- 效果：
-- ①：有手卡的玩家把那些手卡全部丢弃。那之后，那些玩家抽出自身丢弃的数量。
function c72892473.initial_effect(c)
	-- ①：有手卡的玩家把那些手卡全部丢弃。那之后，那些玩家抽出自身丢弃的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c72892473.target)
	e1:SetOperation(c72892473.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的可行性检测（Target）
function c72892473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取回合玩家（自己）的手卡数量
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		-- 获取非回合玩家（对方）的手卡数量
		local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		-- 判断双方手卡总数是否大于0，且需要丢弃手卡的玩家是否能正常抽卡
		return (h1+h2>0) and (Duel.IsPlayerCanDraw(tp,h1) or h1==0) and (Duel.IsPlayerCanDraw(1-tp) or h2==0)
	end
	-- 设置操作信息，表示此效果包含丢弃双方手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	-- 设置操作信息，表示此效果包含双方抽卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 定义效果处理（Operation）
function c72892473.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 记录回合玩家（自己）丢弃前的有效手卡数量
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 记录非回合玩家（对方）丢弃前的有效手卡数量
	local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 获取双方手卡中的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	-- 将双方手卡全部丢弃送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	-- 中断效果处理，使丢弃手卡与抽卡不视为同时进行
	Duel.BreakEffect()
	-- 回合玩家（自己）抽出自身丢弃数量的卡
	Duel.Draw(tp,h1,REASON_EFFECT)
	-- 非回合玩家（对方）抽出自身丢弃数量的卡
	Duel.Draw(1-tp,h2,REASON_EFFECT)
end
