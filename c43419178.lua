--鬼神 水子守命
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「艮神鬼」卡送去墓地，场上1张卡送去墓地。
-- ②：对方把怪兽的效果发动的场合，以自己的墓地·除外状态的1张「艮神鬼」陷阱卡为对象才能发动（场上的里侧表示卡是3张以上的场合，也能作为代替以自己墓地1张陷阱卡为对象）。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 执行对应的效果条件检查或辅助函数处理
function s.initial_effect(c)
	-- 执行对应的效果条件检查或辅助函数处理
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 处理卡片效果的发动条件、目标选择及效果操作
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
	-- 处理卡片效果的发动条件、目标选择及效果操作
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
-- 执行对应的效果条件检查或辅助函数处理
function s.tgfilter(c)
	return c:IsSetCard(0x1e4) and c:IsAbleToGrave()
end
-- 执行对应的效果条件检查或辅助函数处理
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK+LOCATION_ONFIELD)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 执行对应的效果条件检查或辅助函数处理
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 执行对应的效果条件检查或辅助函数处理
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if sg:GetCount()>0 then
			-- 执行对应的效果条件检查或辅助函数处理
			Duel.HintSelection(sg)
			-- 执行对应的效果条件检查或辅助函数处理
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.setfilter(c,res)
	return c:IsFaceupEx() and (c:IsSetCard(0x1e4) or res and c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 执行对应的效果条件检查或辅助函数处理
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 执行对应的效果条件检查或辅助函数处理
	local res=Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,3,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,res) end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,res) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,res)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local tc=Duel.GetFirstTarget()
	-- 执行对应的效果条件检查或辅助函数处理
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SSet(tp,tc)
	end
end
