--鬼神 水子守命
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、特召成功时从卡组及场上送墓效果、以及对方发动怪兽效果时盖放墓地/除外陷阱的效果
function s.initial_effect(c)
	-- 注册同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
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
-- 卡组送墓过滤条件：卡组中可送去墓地的「艮神鬼」卡
function s.tgfilter(c)
	return c:IsSetCard(0x1e4) and c:IsAbleToGrave()
end
-- 发动条件检查：卡组存在可送墓的「艮神鬼」卡且场上存在可送墓的卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以送去墓地的「艮神鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否存在可以送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 设置连锁操作信息：从卡组及场上共将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_ONFIELD)
end
-- 效果处理：从卡组把1张「艮神鬼」卡送去墓地，成功后选场上1张卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择卡组中要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「艮神鬼」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的「艮神鬼」卡送去墓地并确认成功送达墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择场上要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从双方场上选择1张卡
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if sg:GetCount()>0 then
			-- 高亮显示选中的场上卡片
			Duel.HintSelection(sg)
			-- 将选中的场上卡片送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
-- 发动条件：对方玩家发动的怪兽效果
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 盖放对象过滤条件：墓地/除外状态可盖放的「艮神鬼」陷阱卡（若场上里侧卡≥3张则亦可为墓地任意陷阱卡）
function s.setfilter(c,res)
	return c:IsFaceupEx() and (c:IsSetCard(0x1e4) or res and c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 发动准备：判断场上里侧卡数量，选择墓地/除外区符合条件的1张陷阱卡作为对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查双方场上是否存在3张以上的里侧表示卡
	local res=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,res) end
	-- 发动条件检查：墓地/除外区是否存在符合条件且可盖放的陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,res) end
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从墓地/除外区选择1张符合条件的陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,res)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 若对象在墓地，设置连锁操作信息：1张卡离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 效果处理：将对象陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与连锁相关且不受王家长眠之谷限制
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
