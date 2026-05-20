--罪宝合戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上的卡任意数量为对象才能发动（自己场上的卡是以最多有自己的墓地·除外状态的「罪宝」卡数量，对方场上的卡是以最多有对方的墓地·除外状态的「罪宝」卡数量）。那些卡破坏。
-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。场上最多2张卡回到卡组。
local s,id,o=GetID()
-- 初始化效果注册，包含①效果的发动以及②效果在被破坏或除外时的诱发效果注册。
function s.initial_effect(c)
	-- ①：以场上的卡任意数量为对象才能发动（自己场上的卡是以最多有自己的墓地·除外状态的「罪宝」卡数量，对方场上的卡是以最多有对方的墓地·除外状态的「罪宝」卡数量）。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。场上最多2张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选场上的卡回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤自身墓地或除外状态的「罪宝」卡。
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x19e)
end
-- 过滤可以作为效果对象且未超过双方各自最大可选数量限制的场上的卡。
function s.desfilter2(c,e,tp,gc1,gc2)
	return c:IsCanBeEffectTarget(e) and ((c:IsControler(tp) and gc1>0) or (c:IsControler(1-tp) and gc2>0))
end
-- ①效果的发动准备，计算双方墓地及除外状态的「罪宝」卡数量，并让玩家选择对应数量内的场上卡片作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己墓地及除外状态的「罪宝」卡数量。
	local gc1=Duel.GetMatchingGroupCount(s.desfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	-- 计算对方墓地及除外状态的「罪宝」卡数量。
	local gc2=Duel.GetMatchingGroupCount(s.desfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if chkc then return chkc:IsOnField() and chkc:IsCanBeEffectTarget(e) and chkc~=e:GetHandler() end
	-- 判断场上是否存在至少1张满足对象选择条件的卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),e,tp,gc1,gc2) end
	-- 向玩家发送选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=Group.CreateGroup()
	while true do
		-- 获取当前场上所有满足对象选择条件的卡片组。
		local g=Duel.GetMatchingGroup(s.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,sg,e,tp,gc1,gc2)
		if g:IsContains(e:GetHandler()) then
			g:RemoveCard(e:GetHandler())
		end
		if #g==0 then
			break
		end
		-- 在循环选择中，向玩家发送选择要破坏的卡的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sc=g:SelectUnselect(sg,tp,#sg>0,#sg>0,1,99)
		if not sc then
			break
		elseif g:IsContains(sc) then
			g:RemoveCard(sc)
			sg:AddCard(sc)
			if sc:IsControler(tp) then
				gc1=gc1-1
			else
				gc2=gc2-1
			end
		else
			sg:RemoveCard(sc)
			g:AddCard(sc)
			if sc:IsControler(tp) then
				gc1=gc1+1
			else
				gc2=gc2+1
			end
		end
	end
	-- 将选择的卡片组设置为当前效果的处理对象。
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息为破坏选定的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的处理结果，将仍存在于场上的对象卡片破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 因效果将这些卡片破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 判断是否满足“盖放的这张卡被对方所发动的效果所破坏的场合或者所除外的场合”的发动条件。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and re:IsActivated()
end
-- ②效果的发动准备，检查场上是否存在可以回到卡组的卡并设置操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在至少1张可以回到卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可以回到卡组的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息为将卡片送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果的处理结果，让玩家选择场上最多2张卡回到卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要返回卡组的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择场上1到2张可以回到卡组的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if g:GetCount()>0 then
		-- 为选中的卡片显示被选择的动画效果。
		Duel.HintSelection(g)
		-- 因效果将选中的卡片送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
