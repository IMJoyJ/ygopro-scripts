--光なき影 ア＝バオ・ア・クゥー
-- 效果：
-- 包含恶魔族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，可以丢弃1张手卡，从以下效果选择1个发动。
-- ●场上1张卡破坏。
-- ●这张卡直到结束阶段除外，从自己墓地把1只光·暗属性怪兽特殊召唤。
-- ②：自己准备阶段才能发动。自己抽出自己墓地的怪兽的种族种类的数量。那之后，选抽出数量的自己手卡用喜欢的顺序回到卡组下面。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续并注册两个效果
function s.initial_effect(c)
	-- 设置连接召唤需要至少2只包含恶魔族的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- 效果①：主要阶段可发动，丢弃1张手卡，选择破坏场上1张卡或除外自身并特殊召唤光·暗属性怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.accon)
	e1:SetCost(s.accost)
	e1:SetTarget(s.actarget)
	e1:SetOperation(s.acoperation)
	c:RegisterEffect(e1)
	-- 效果②：准备阶段可发动，抽墓地怪兽数量等于种族种类数，并将相同数量的手卡放回卡组底
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.dract)
	c:RegisterEffect(e2)
end
-- 连接召唤的过滤函数，检查是否有恶魔族怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- 效果①的发动条件，判断是否在主要阶段
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为开始阶段或结束阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的费用，丢弃1张手卡
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可丢弃的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤的过滤函数，筛选光·暗属性且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的目标选择，判断是否可以发动破坏或除外并特殊召唤的效果
function s.actarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否存在可破坏的卡
	local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	-- 判断自身是否可除外且有空怪兽区
	local b2=c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0
		-- 判断墓地是否有符合条件的光·暗属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	-- 选择效果选项
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2)},  --"破坏"
		{b2,aux.Stringid(id,3)})  --"除外并特殊召唤"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取场上所有卡的集合用于破坏效果
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		-- 设置除外操作的信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
		-- 设置特殊召唤操作的信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果①的处理，根据选择的效果执行破坏或除外并特殊召唤
function s.acoperation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上要破坏的卡
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 显示选中的卡被选为对象
			Duel.HintSelection(g)
			-- 执行破坏操作
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		local c=e:GetHandler()
		-- 判断自身是否有效且成功除外
		if c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			if c:GetOriginalCode()==id then
				c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
				-- 注册一个在结束阶段返回场上的效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END)
				e1:SetLabelObject(c)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				-- 将效果注册到玩家环境中
				Duel.RegisterEffect(e1,tp)
			end
			-- 检查是否有空怪兽区
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查墓地是否存在符合条件的怪兽
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 选择要特殊召唤的卡
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				-- 执行特殊召唤操作
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 返回场上的条件判断函数
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
-- 返回场上的处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 效果②的发动条件，判断是否为自己的准备阶段
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 效果②的目标设定，计算抽卡数量并设置操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取墓地所有怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local ct=g:GetClassCount(Card.GetRace)
	-- 检查是否可以发动效果②
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置目标参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	-- 设置放回卡组底的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,LOCATION_HAND)
end
-- 效果②的处理，执行抽卡并选择手卡放回卡组底
function s.dract(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地所有怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local ct=g:GetClassCount(Card.GetRace)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽卡操作
	local dc=Duel.Draw(p,ct,REASON_EFFECT)
	if dc>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要放回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要放回卡组的卡
		local rg=Duel.GetFieldGroup(p,LOCATION_HAND,0):Select(p,dc,dc,nil)
		-- 洗切玩家手牌
		Duel.ShuffleHand(p)
		-- 将选中的卡放回卡组底
		aux.PlaceCardsOnDeckBottom(p,rg)
	end
end
