--トライアングル－O
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
-- ②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
local s,id,o=GetID()
-- 定义三角阵-O的初始效果注册函数，先登记关联卡名，再为卡注册两个效果：①：条件满足时破坏全场卡并使效果伤害由对方代受；②：除外墓地自身，选3只特定怪兽回卡组并抽3张。
function s.initial_effect(c)
	-- 将「水晶头骨」「阿育王铁柱」「卡布雷拉石」的卡号记录在三角阵-O上，用于规则上识别该效果文本记载的卡名。
	aux.AddCodeList(c,7903368,58996839,84384943)
	-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
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
	-- ②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动COST为把墓地中的这张卡除外（aux.bfgcost封装了除外自身这一代价操作）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 定义过滤器s.desfilter：判断卡片是否为表侧表示且卡号等于指定code，用于检查场上的指定怪兽是否存在。
function s.desfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 定义①效果的发动条件s.descon：自己场上同时存在表侧表示的「水晶头骨」「阿育王铁柱」「卡布雷拉石」时才能发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「水晶头骨」（卡号7903368）。
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,7903368)
		-- 检查自己场上是否存在至少1张表侧表示的「阿育王铁柱」（卡号58996839）。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,58996839)
		-- 检查自己场上是否存在至少1张表侧表示的「卡布雷拉石」（卡号84384943）。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,84384943)
end
-- 定义①效果发动时的目标选择与操作信息设置：若合法，则获取双方场上除自身外所有卡，并设定为将要破坏的对象。
function s.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动合法性检查：场上是否存在除自身以外的卡（有卡可被破坏时才可发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取当前双方场上除自身以外的所有卡，作为即将被破坏的卡集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置当前连锁的破坏操作信息：将破坏上述卡组g中的全部卡，数量为g:GetCount()，以便系统正确识别破坏事件。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：取得双方场上除自身外的所有卡；给己方玩家注册一个本回合结束阶段重置的效果伤害反射效果；然后将这些卡全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上除自身以外的所有卡，作为破坏对象组（aux.ExceptThisCard(e)用于排除与效果e关联的发动卡自身）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local c=e:GetHandler()
	-- ①：场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果反射伤害的永续效果注册给己方玩家，使己方受到的效果伤害由对方代受，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 以效果原因破坏g中的所有卡，对应“场上的卡全部破坏”的处理。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 定义反射伤害判定函数：仅当伤害原因为效果伤害（r含有REASON_EFFECT）时返回true，即只反射效果伤害。
function s.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 定义②效果对象过滤器s.tdfilter：对象必须是「水晶头骨」「阿育王铁柱」「卡布雷拉石」之一，位于墓地且能返回卡组，并且能被当前效果取为对象。
function s.tdfilter(c,e)
	return c:IsCode(7903368,58996839,84384943) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 定义②效果的目标选择与操作信息设置：从自己墓地选择3张卡名互不相同的指定怪兽卡作为对象，并设置回卡组与抽3张的操作信息；同时检查种类足够与可抽卡。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 获取自己墓地中满足②效果对象条件的全部卡（三种「水晶头骨」系怪兽）。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- ②效果发动合法性检查：自己墓地中符合条件的怪兽卡名种类至少有3种（即三种各1只），且己方可以抽3张卡。
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 and Duel.IsPlayerCanDraw(tp,3) end
	-- 弹出“请选择要返回卡组的卡”的选择提示，用于让玩家从墓地选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置后续选择子组的附加检查条件为“卡名互不相同”（aux.dncheck），确保选出的是三种不同名的卡。
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从墓地候选组g中选择3张卡作为对象，选择时应用上述卡名不同检查，返回选中的卡组sg。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,3,3)
	-- 清除附加检查条件，避免影响后续其他选择操作。
	aux.GCheckAdditional=nil
	-- 将选中的3张卡设为当前连锁的效果对象（取对象），建立对象与效果的关联。
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息：本效果将把对象卡返回卡组（CATEGORY_TODECK），目标组为g，预期数量为3。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置当前连锁的操作信息：本效果之后将让己方玩家抽3张卡（CATEGORY_DRAW），目标玩家为tp，数量为3。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 定义②效果处理：取得仍与效果关联的对象卡，将其返回卡组并洗切；若确有卡回到卡组，则错开时点后让自己抽3张。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤出仍然与效果e有关的卡（对象仍有效且未离场）作为实际返回卡组的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 以效果原因将tg中的卡返回持有者卡组，指定SEQ_DECKSHUFFLE表示返回后需要洗切卡组。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才被实际送回卡组的卡片组，用于确认返回操作的结果。
	local g=Duel.GetOperatedGroup()
	-- 若确有卡回到了卡组，则洗切己方卡组以完成卡组的随机化。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		-- 中断当前效果处理，使“回卡组”与“抽卡”的时点分开，避免不正确的连锁触发。
		Duel.BreakEffect()
		-- 以效果原因让己方玩家抽3张卡，对应“那之后，自己抽3张”.
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
