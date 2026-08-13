--クリオスフィンクス
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，场上的怪兽回到持有者手卡时，那只怪兽的持有者从手卡选择1张卡送去墓地。
function c18654201.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，场上的怪兽回到持有者手卡时
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetOperation(c18654201.regop)
	c:RegisterEffect(e1)
	-- 那只怪兽的持有者从手卡选择1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18654201,0))  --"手牌送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+18654201)
	e2:SetTarget(c18654201.hdtg)
	e2:SetOperation(c18654201.hdop)
	c:RegisterEffect(e2)
end
-- 筛选出当前控制者为tp、之前位于场上怪兽区域且之前在场时为怪兽的卡，即从场上回到持有者手卡的怪兽。
function c18654201.filter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
end
-- 监听场上的怪兽回到持有者手卡的事件，分别判断玩家0和玩家1是否有符合条件的怪兽回手，并根据情况触发本卡的自定义事件，以标记需要丢弃手牌的玩家。
function c18654201.regop(e,tp,eg,ep,ev,re,r,rp)
	local p1=false local p2=false
	if eg:IsExists(c18654201.filter,1,nil,0) then p1=true end
	if eg:IsExists(c18654201.filter,1,nil,1) then p2=true end
	local c=e:GetHandler()
	if p1 and p2 then
		-- 若双方都有怪兽回手，则以PLAYER_ALL作为适用玩家向本卡触发自定义事件，表示双方玩家都需各选1张手牌送去墓地。
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,PLAYER_ALL,0)
	elseif p1 then
		-- 若只有玩家0的怪兽回手，则以玩家0作为适用玩家向本卡触发自定义事件，表示仅玩家0需选1张手牌送去墓地。
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,0,0)
	elseif p2 then
		-- 若只有玩家1的怪兽回手，则以玩家1作为适用玩家向本卡触发自定义事件，表示仅玩家1需选1张手牌送去墓地。
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+18654201,re,r,rp,1,0)
	end
end
-- 作为诱发效果的发动条件检查：确认本卡与效果仍有关联，然后设置送墓的操作信息，准备让对应玩家从手牌选1张卡送去墓地。
function c18654201.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息：本次效果为从手卡送1张卡去墓地，目标玩家为ep，检索区域为手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,ep,LOCATION_HAND)
end
-- 执行效果处理：若本卡已与效果失联或变为里侧表示则效果不适用；否则根据ep玩家，让对应玩家（ep为PLAYER_ALL时双方）各从手牌选1张卡送去墓地。
function c18654201.hdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	if ep==PLAYER_ALL then
		-- 让玩家0从手牌选择1张卡，以效果原因送去墓地。
		Duel.DiscardHand(0,nil,1,1,REASON_EFFECT)
		-- 让玩家1从手牌选择1张卡，以效果原因送去墓地。
		Duel.DiscardHand(1,nil,1,1,REASON_EFFECT)
	else
		-- 让适用玩家ep从手牌选择1张卡，以效果原因送去墓地。
		Duel.DiscardHand(ep,nil,1,1,REASON_EFFECT)
	end
end
