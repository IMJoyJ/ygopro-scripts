--鬼神 水子守命
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片初始化效果：为这张卡添加同调召唤手续，以及特殊召唤成功时堆墓「艮神鬼」卡并送墓场上卡的效果、对方发动怪兽效果时盖放墓地/除外区陷阱卡的效果。
function s.initial_effect(c)
	-- 为这张卡注册使用1只调整及1只以上调整以外怪兽的同调召唤手续。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 卡组送墓过滤函数：检查卡片是否属于「艮神鬼」卡且能送去墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x1e4) and c:IsAbleToGrave()
end
-- 特殊召唤成功时送墓效果的目标检查函数：检查卡组是否存在「艮神鬼」卡且场上存在可送去墓地的卡，并设置操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以送去墓地的「艮神鬼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否存在至少1张可以送去墓地的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置当前连锁的操作信息为将2张卡（卡组1张+场上1张）送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_ONFIELD)
end
-- 特殊召唤成功时送墓效果的处理函数：先从卡组把1张「艮神鬼」卡送去墓地，若成功送墓则再选择场上1张卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示要求玩家选择要从卡组送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张「艮神鬼」卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选「艮神鬼」卡成功通过效果送去墓地且到达墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 弹出提示要求玩家选择要从场上送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从场上选择1张卡。
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if sg:GetCount()>0 then
			-- 高亮显示在场上被选为目标的卡片。
			Duel.HintSelection(sg)
			-- 将选中的场上卡片送去墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
-- 盖放效果条件检查函数：判断是否由对方玩家发动的怪兽效果。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 盖放陷阱卡过滤函数：检查卡片是否为陷阱卡且能盖放，要求为「艮神鬼」陷阱卡（若场上里侧表示卡在3张以上则可以为墓地任意陷阱卡）。
function s.setfilter(c,res)
	return c:IsFaceupEx() and (c:IsSetCard(0x1e4) or res and c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 盖放效果的目标选择函数：检查场上里侧表示卡数量，在墓地/除外区选择符合条件的陷阱卡作为对象，并设置操作信息与提示。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查场上（双方）是否存在至少3张里侧表示卡。
	local res=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,res) end
	-- 检查自己的墓地或除外区是否存在至少1张符合条件的陷阱卡作为发动目标。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,res) end
	-- 弹出提示要求玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 在自己墓地或除外区选择1张符合条件的陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,res)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 若选择的对象在墓地，设置操作信息为将1张卡从墓地离开。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 盖放效果的处理函数：将作为对象的墓地或除外区陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与连锁有联系且不受王家长眠之谷影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡在自己场上盖放。
		Duel.SSet(tp,tc)
	end
end
