--サプライズ・チェーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：同一连锁上没有复数次同名卡的效果发动的场合，那个连锁2以后才能发动。这张卡的发动时积累的连锁数量的以下效果适用。
-- ●2个以上：把这张卡的发动时积累的连锁数量的卡从自己卡组上面翻开，用喜欢的顺序回到卡组上面。
-- ●3个以上：从自己卡组上面把1张卡送去墓地。
-- ●4个以上：自己从卡组抽1张。
function c70491413.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：同一连锁上没有复数次同名卡的效果发动的场合，那个连锁2以后才能发动。这张卡的发动时积累的连锁数量的以下效果适用。●2个以上：把这张卡的发动时积累的连锁数量的卡从自己卡组上面翻开，用喜欢的顺序回到卡组上面。●3个以上：从自己卡组上面把1张卡送去墓地。●4个以上：自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,70491413+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c70491413.condition)
	e1:SetTarget(c70491413.target)
	e1:SetOperation(c70491413.activate)
	c:RegisterEffect(e1)
end
-- 过滤/发动条件：检查当前连锁数以及连锁中是否存在同名卡的发动
function c70491413.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须在连锁2及以上发动（当前连锁数大于0，因为此卡发动时会使连锁数+1，所以GetCurrentChain()>0即代表此卡作为连锁2或以上发动），且当前连锁中没有同名卡的效果发动
	return Duel.GetCurrentChain()>0 and Duel.CheckChainUniqueness()
end
-- 效果的目标处理：检查卡组数量是否足够，并根据连锁数设置对应的效果分类和操作信息
function c70491413.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前连锁数（即这张卡发动时积累的连锁数量）
	local cl=Duel.GetCurrentChain()
	-- 若为检查可行性阶段，则要求自己卡组的卡片数量必须大于或等于当前连锁数
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=cl
		-- 且若连锁数在3以上，自己必须能够将卡组顶端的卡送去墓地
		and (cl<3 or Duel.IsPlayerCanDiscardDeck(tp,1))
		-- 且若连锁数在4以上，自己必须能够从卡组抽卡
		and (cl<4 or Duel.IsPlayerCanDraw(tp,1))
	end
	local cat=0
	if cl>=3 then
		cat=cat|CATEGORY_TOGRAVE
		-- 设置操作信息：从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
	if cl>=4 then
		cat=cat|CATEGORY_DRAW
		-- 设置操作信息：自己抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	e:SetCategory(cat)
end
-- 效果的处理：根据发动时的连锁数，依次适用对应的效果
function c70491413.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时积累的连锁数量
	local cl=Duel.GetCurrentChain()
	if cl>=2 then
		-- 确认自己卡组最上方与连锁数量相同张数的卡
		Duel.ConfirmDecktop(tp,cl)
		-- 获取自己卡组最上方与连锁数量相同张数的卡片组
		local g=Duel.GetDecktopGroup(tp,cl)
		if g:GetCount()>0 then
			-- 让玩家用喜欢的顺序将这些卡放回卡组上面
			Duel.SortDecktop(tp,tp,g:GetCount())
		end
	end
	if cl>=3 then
		-- 中断当前效果，使后续的送去墓地处理不与之前的排序同时处理
		Duel.BreakEffect()
		-- 将自己卡组最上方1张卡送去墓地
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
	if cl>=4 then
		-- 中断当前效果，使后续的抽卡处理不与之前的送去墓地同时处理
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
