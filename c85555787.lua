--悪のデッキ破壊ウイルス
-- 效果：
-- ①：把自己场上1只攻击力3000以下的暗属性怪兽解放才能发动。那只怪兽的攻击力每有500，对方从自身的手卡·卡组选1张卡破坏。为这张卡发动而把攻击力2000以上的怪兽解放的场合，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的怪兽全部破坏。此外，这张卡的效果破坏送去墓地的卡在破坏的回合不能把效果发动。
function c85555787.initial_effect(c)
	-- ①：把自己场上1只攻击力3000以下的暗属性怪兽解放才能发动。那只怪兽的攻击力每有500，对方从自身的手卡·卡组选1张卡破坏。为这张卡发动而把攻击力2000以上的怪兽解放的场合，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的怪兽全部破坏。此外，这张卡的效果破坏送去墓地的卡在破坏的回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMINGS_CHECK_MONSTER)
	e1:SetCost(c85555787.cost)
	e1:SetTarget(c85555787.target)
	e1:SetOperation(c85555787.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上攻击力在指定数值以下的暗属性怪兽
function c85555787.costfilter(c,matk)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(matk)
end
-- 发动代价：设置标记以在target中进行解放处理
function c85555787.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 发动准备：检查并选择场上1只满足条件的暗属性怪兽解放，并根据其攻击力设置破坏的操作信息
function c85555787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手卡和卡组的卡片总数
	local dc=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND+LOCATION_DECK)
	local matk=math.min(3000,dc*500)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在可解放的满足条件的怪兽
		return matk>0 and Duel.CheckReleaseGroup(tp,c85555787.costfilter,1,nil,matk)
	end
	-- 让玩家选择1只满足条件的怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c85555787.costfilter,1,1,nil,matk)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
	local ct=math.floor(atk/500)
	-- 设置效果处理时的操作信息：从对方的手卡或卡组破坏指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,ct,1-tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：对方选择手卡·卡组的卡破坏，若解放的怪兽攻击力在2000以上，则注册3回合内确认对方抽卡并破坏怪兽的效果
function c85555787.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	local ct=math.floor(atk/500)
	-- 让对方从自身的手卡·卡组选择指定数量的卡
	local g=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_DECK+LOCATION_HAND,0,ct,ct,nil)
	-- 若成功选择并破坏了这些卡
	if g:GetCount()~=0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取因该效果破坏并送去墓地的卡片组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		-- 遍历所有被破坏送去墓地的卡
		for oc in aux.Next(og) do
			-- 这张卡的效果破坏送去墓地的卡在破坏的回合不能把效果发动。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_TRIGGER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			oc:RegisterEffect(e3)
		end
	end
	if atk>=2000 then
		-- 用对方回合计算的3回合内对方抽到的卡全部确认，那之内的怪兽全部破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_DRAW)
		e1:SetOperation(c85555787.desop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		-- 注册全局效果：在对方抽卡时触发确认并破坏的效果
		Duel.RegisterEffect(e1,tp)
		-- 用对方回合计算的3回合内
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetCondition(c85555787.turncon)
		e2:SetOperation(c85555787.turnop)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		-- 注册全局效果：在每个回合结束时累计回合计数器
		Duel.RegisterEffect(e2,tp)
		e2:SetLabelObject(e1)
		c:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
		c85555787[c]=e2
	end
end
-- 抽卡时效果处理：确认对方抽到的卡，并将其中所有的怪兽卡破坏，且被破坏送去墓地的卡在当回合不能发动效果
function c85555787.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local c=e:GetHandler()
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 给对方（此效果的发动者）确认抽到的手卡
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 若成功破坏了抽到的怪兽卡
	if Duel.Destroy(dg,REASON_EFFECT)~=0 then
		-- 获取因该效果破坏并送去墓地的卡片组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		-- 遍历所有被破坏送去墓地的卡
		for oc in aux.Next(og) do
			-- 这张卡的效果破坏送去墓地的卡在破坏的回合不能把效果发动。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_TRIGGER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			oc:RegisterEffect(e3)
		end
	end
	-- 洗切对方的手卡
	Duel.ShuffleHand(ep)
end
-- 回合结束效果的条件：当前回合是对方的回合
function c85555787.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 回合结束效果处理：增加回合计数器，满3个对方回合后重置相关效果
function c85555787.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		e:GetOwner():ResetFlagEffect(1082946)
	end
end
