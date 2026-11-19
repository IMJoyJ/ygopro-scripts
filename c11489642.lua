--トライアングル－O
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
-- ②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
local s,id,o=GetID()
-- 初始化卡片效果：记录关联卡名，并注册破坏全场且代受效果伤害的①效果与墓地除外回收抽卡的②效果，两者共享每回合1次的发动次数限制。
function s.initial_effect(c)
	-- 记录这张卡的卡文上记载了「水晶头骨」「阿育王铁柱」「卡布雷拉石」的卡名。
	aux.AddCodeList(c,7903368,58996839,84384943)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"场上的卡全部破坏"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destarget)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且卡名为指定卡号（code）。
function s.desfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- ①效果的发动条件判定：检查自己场上是否同时存在表侧表示的「水晶头骨」「阿育王铁柱」「卡布雷拉石」。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「水晶头骨」。
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,7903368)
		-- 且检查自己场上是否存在至少1张表侧表示的「阿育王铁柱」。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,58996839)
		-- 且检查自己场上是否存在至少1张表侧表示的「卡布雷拉石」。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,84384943)
end
-- ①效果的目标处理函数：检查双方场上是否存在这张卡以外的其他卡，并申报破坏这些卡的操作信息。
function s.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查双方场上是否存在至少1张这张卡以外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取双方场上除这张卡外的所有卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：预计破坏场上除这张卡外的所有卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的效果处理函数：为自己注册直到回合结束时将效果伤害反射给对方的效果，并将场上所有其他卡破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上除与本效果有联系的这张卡外的所有卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local c=e:GetHandler()
	-- 场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册一个直到回合结束时生效的全局效果，将自己受到的效果伤害反射给对方。
	Duel.RegisterEffect(e1,tp)
	-- 将场上获取到的所有卡片以效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 伤害反射的条件判定函数：判断伤害原因是否包含效果伤害（REASON_EFFECT）。
function s.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数：判断卡片是否为「水晶头骨」「阿育王铁柱」「卡布雷拉石」之一、能否返回卡组且能否成为效果对象。
function s.tdfilter(c,e)
	return c:IsCode(7903368,58996839,84384943) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- ②效果的对象选择与目标处理函数：从自己墓地选取上述3只卡名各不相同的怪兽作为对象，并申报回卡组和抽3张卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc,e) end
	-- 获取自己墓地中满足回收与取对象条件的三张关联卡卡片组。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 发动可行性检测：检查自己墓地中是否至少集齐3种不同卡名的目标怪兽，且自己能够抽3张卡。
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 and Duel.IsPlayerCanDraw(tp,3) end
	-- 向自己发送选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置选卡附加检查条件，要求所选卡片组中的卡名必须互不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 让自己在候选卡片组中选择3张卡名各不相同的怪兽卡。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,3,3)
	-- 清除选卡附加检查条件。
	aux.GCheckAdditional=nil
	-- 将选中的3张卡设为当前连锁的效果对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：预计将3张怪兽卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息：预计由自己玩家抽3张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- ②效果的效果处理函数：将仍与效果有联系的对象怪兽洗回卡组，若至少有1只回到卡组则洗切卡组后中断效果并抽3张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组，并过滤保留仍与本效果有联系的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标怪兽以效果送回各自持有者的卡组并标记洗牌。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际被送回卡组的卡片组。
	local g=Duel.GetOperatedGroup()
	-- 若实际返回卡组的卡中有回到卡组区域的卡，则洗切自己的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		-- 中断当前效果处理，使之后的抽卡与前面的回卡组处理视为不同时进行。
		Duel.BreakEffect()
		-- 使自己以效果从卡组抽3张卡。
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
