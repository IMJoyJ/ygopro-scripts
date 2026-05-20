--原質の臨界超過
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽的效果·魔法·陷阱卡发动时才能发动。自己场上的「原质炉」超量怪兽作为超量素材中的1张自己的卡加入手卡，那个发动无效。那之后，加入手卡的卡种类的以下效果适用。
-- ●怪兽：选自己1张手卡回到卡组最下面。
-- ●魔法：自己场上的「原质炉」超量怪兽的攻击力上升1000。
-- ●陷阱：可以把这个效果加入手卡的卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义该卡的发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：怪兽的效果·魔法·陷阱卡发动时才能发动。自己场上的「原质炉」超量怪兽作为超量素材中的1张自己的卡加入手卡，那个发动无效。那之后，加入手卡的卡种类的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件判断函数。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁中发动的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤自己场上表侧表示的「原质炉」超量怪兽。
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x160)
end
-- 过滤可以加入手卡且原本持有者为自己的卡。
function s.ovfilter(c,tp)
	return c:IsAbleToHand() and c:GetOwner()==tp
end
-- 效果发动的目标选择与合法性检查函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Group.CreateGroup()
	-- 获取自己场上所有的「原质炉」超量怪兽。
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if xg:GetCount()<1 then return false end
	-- 遍历这些「原质炉」超量怪兽。
	for tc in aux.Next(xg) do
		local hg=tc:GetOverlayGroup()
		if hg:GetCount()>0 then
			rg:Merge(hg)
		end
	end
	if chk==0 then return rg and rg:FilterCount(s.ovfilter,nil,tp)>0 end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 过滤不受该效果影响的、自己场上表侧表示的「原质炉」超量怪兽。
function s.atkfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x160)
		and not c:IsImmuneToEffect(e)
end
-- 效果发动的实际处理函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Group.CreateGroup()
	-- 获取自己场上所有的「原质炉」超量怪兽。
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if xg:GetCount()<1 then return end
	-- 遍历这些「原质炉」超量怪兽。
	for tc in aux.Next(xg) do
		local hg=tc:GetOverlayGroup()
		if hg:GetCount()>0 then
			rg:Merge(hg)
		end
	end
	if rg and rg:FilterCount(s.ovfilter,nil,tp)>0 then
		local tc=rg:FilterSelect(tp,s.ovfilter,1,1,nil,tp):GetFirst()
		-- 将选中的超量素材加入手卡，并确认该卡已成功加入手卡。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			-- 给对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,tc)
			-- 洗切自己的手卡。
			Duel.ShuffleHand(tp)
			-- 尝试使该连锁的发动无效。
			if Duel.NegateActivation(ev) then
				-- 中断效果处理，使后续效果与无效发动的处理不视为同时进行。
				Duel.BreakEffect()
				-- 如果加入手卡的卡是怪兽，且自己手卡有可以回到卡组的卡。
				if tc:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
					-- 选择自己1张手卡。
					local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
					-- 将选中的手卡回到卡组最下面。
					Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
				-- 如果加入手卡的卡是魔法，且自己场上有符合条件的「原质炉」超量怪兽。
				if tc:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil,e) then
					-- 获取自己场上所有符合条件的「原质炉」超量怪兽。
					local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
					if g:GetCount()>0 then
						-- 遍历这些「原质炉」超量怪兽。
						for ac in aux.Next(g) do
							-- ●魔法：自己场上的「原质炉」超量怪兽的攻击力上升1000。
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e1:SetCode(EFFECT_UPDATE_ATTACK)
							e1:SetValue(1000)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD)
							ac:RegisterEffect(e1)
						end
					end
				end
				if tc:IsType(TYPE_TRAP)
					-- 检查该陷阱卡是否为场地卡，或者自己场上是否有可用的魔法与陷阱区域。
					and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
					and tc:IsSSetable(true)
					-- 询问玩家是否选择将该卡盖放。
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否盖放？"
					-- 将该卡在自己场上盖放。
					Duel.SSet(tp,tc)
				end
			end
		end
	end
end
