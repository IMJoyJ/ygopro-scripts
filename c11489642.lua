--トライアングル－O
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
-- ②：把墓地的这张卡除外，以自己墓地的「水晶头骨」「阿育王铁柱」「卡布雷拉石」各1只为对象才能发动。那些怪兽回到卡组。那之后，自己抽3张。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码列表，用于检查是否包含「水晶头骨」「阿育王铁柱」「卡布雷拉石」
	aux.AddCodeList(c,7903368,58996839,84384943)
	-- ①：自己场上有「水晶头骨」「阿育王铁柱」「卡布雷拉石」全部存在的场合才能发动。场上的卡全部破坏。这个回合，自己受到的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 破坏效果的过滤函数，用于检查场上是否包含指定代码的卡
function s.desfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 效果①的发动条件函数，检查场上是否同时存在三种指定卡片
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「水晶头骨」
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,7903368)
		-- 检查自己场上是否存在「阿育王铁柱」
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,58996839)
		-- 检查自己场上是否存在「卡布雷拉石」
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,84384943)
end
-- 效果①的目标选择函数
function s.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①的目标选择条件，即场上存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置连锁操作信息，指定将要破坏的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡（排除此卡）的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local c=e:GetHandler()
	-- 将效果①的伤害反射效果注册到场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害反射效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 将场上所有卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 伤害反射效果的值函数，判断是否为效果伤害
function s.val(e,re,ev,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 效果②的卡组过滤函数，用于筛选墓地中的指定卡片
function s.tdfilter(c,e)
	return c:IsCode(7903368,58996839,84384943) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 效果②的目标选择函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 获取玩家墓地中的指定卡片组
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 判断是否满足效果②的目标选择条件，即墓地中存在至少3张不同种类的指定卡片且玩家可以抽3张卡
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3 and Duel.IsPlayerCanDraw(tp,3) end
	-- 提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 从符合条件的卡片中选择3张不重复卡名的卡片
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,3,3)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 设置效果②的目标卡片
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息，指定将要送回卡组的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置连锁操作信息，指定将要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果②的处理函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标卡片送回卡组并洗切卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若送回卡组的卡片中有进入卡组的，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 让玩家抽3张卡
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
