--クリオスフィンクス
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，场上的怪兽回到持有者手卡时，那只怪兽的持有者从手卡选择1张卡送去墓地。
function c18654201.initial_effect(c)
	-- 效果原文：只要这张卡在自己场上表侧表示存在，场上的怪兽回到持有者手卡时，那只怪兽的持有者从手卡选择1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetOperation(c18654201.regop)
	c:RegisterEffect(e1)
	-- 效果原文：只要这张卡在自己场上表侧表示存在，场上的怪兽回到持有者手卡时，那只怪兽的持有者从手卡选择1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18654201,0))  --"手牌送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+18654201)
	e2:SetTarget(c18654201.hdtg)
	e2:SetOperation(c18654201.hdop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查怪兽从场上回到手牌时是否满足条件（控制者为tp，之前在怪兽区，且类型为怪兽）
function c18654201.filter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
end
-- 判断是否有怪兽从场上回到手牌，若存在则标记对应玩家触发事件
function c18654201.regop(e,tp,eg,ep,ev,re,r,rp)
	local p1=false local p2=false
	if eg:IsExists(c18654201.filter,1,nil,0) then p1=true end
	if eg:IsExists(c18654201.filter,1,nil,1) then p2=true end
	local c=e:GetHandler()
	if p1 and p2 then
		-- 为双方玩家触发自定义事件，表示双方都需处理效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,PLAYER_ALL,0)
	elseif p1 then
		-- 为玩家0触发自定义事件，表示玩家0需处理效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,0,0)
	elseif p2 then
		-- 为玩家1触发自定义事件，表示玩家1需处理效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,1,0)
	end
end
-- 设置效果的目标为对方手牌，准备执行送去墓地的操作
function c18654201.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息，表示将从对方手牌中送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,ep,LOCATION_HAND)
end
-- 执行效果操作，根据玩家是否为双方分别处理丢弃手牌
function c18654201.hdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	if ep==PLAYER_ALL then
		-- 玩家0丢弃1张手牌到墓地
		Duel.DiscardHand(0,nil,1,1,REASON_EFFECT)
		-- 玩家1丢弃1张手牌到墓地
		Duel.DiscardHand(1,nil,1,1,REASON_EFFECT)
	else
		-- 根据玩家ep丢弃1张手牌到墓地
		Duel.DiscardHand(ep,nil,1,1,REASON_EFFECT)
	end
end
