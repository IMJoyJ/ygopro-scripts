--トライアングル－O
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
-- ②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
local s,id,o=GetID()
-- 注册卡片效果，包括两个效果：①破坏场上所有卡并使自己受到的效果伤害由对方代受；②从墓地除外自身并回收指定怪兽，然后抽3张卡
function s.initial_effect(c)
	-- 记录该卡与「水晶头骨」「阿育王铁柱」「卡布雷拉石」这三张卡的关联
	aux.AddCodeList(c,7903368,58996839,84384943)
	-- 效果①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
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
	-- 效果②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将自身从墓地除外作为效果②的发动费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在指定编号的卡
function s.desfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 判断自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上有「水晶头骨」存在的场合
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,7903368)
		-- 判断自己场上有「阿育王铁柱」存在的场合
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,58996839)
		-- 判断自己场上有「卡布雷拉石」存在的场合
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,84384943)
end
-- 效果①的发动时点处理，检查场上是否存在至少1张卡
function s.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果①的处理信息，指定破坏场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理函数，将场上所有卡破坏并设置反射伤害效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的卡片组，排除自身
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local c=e:GetHandler()
	-- 设置反射伤害效果，使自己受到的效果伤害由对方代受
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将反射伤害效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 将场上所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 反射伤害效果的值函数，判断是否为效果伤害
function s.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 过滤函数，用于判断墓地中的卡是否为「水晶头骨」「阿育王铁柱」「卡布雷拉石」且可送回卡组
function s.tdfilter(c,e)
	return c:IsCode(7903368,58996839,84384943) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动时点处理，选择3张不同卡名的墓地怪兽并设置处理信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 获取墓地中的「水晶头骨」「阿育王铁柱」「卡布雷拉石」怪兽组
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 检查是否满足发动条件：墓地有3张不同卡名的怪兽且自己可以抽3张卡
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 and Duel.IsPlayerCanDraw(tp,3) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 从满足条件的怪兽中选择3张卡
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,3,3)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 设置效果②的目标卡组
	Duel.SetTargetCard(sg)
	-- 设置效果②的处理信息，指定送回卡组3张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置效果②的处理信息，指定自己抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果②的处理函数，将目标怪兽送回卡组并抽3张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标卡组并筛选出与效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标怪兽送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡组
	local g=Duel.GetOperatedGroup()
	-- 若送回卡组的卡中有卡在卡组中，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 让玩家抽3张卡
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
