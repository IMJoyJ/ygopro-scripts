--道化の一座 ドリッシュ
-- 效果：
-- 仪式·融合·同调·超量·灵摆怪兽2只
-- ①：上级召唤的自己怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的连接怪兽全部回到额外卡组。
-- ●双方让自身手卡全部回到卡组。那之后，双方抽出自身回去的数量。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括连接召唤手续、①使上级召唤的己方怪兽在同一次战斗阶段可作2次攻击的永续效果、②被解放时可选择使场上和墓地连接怪兽回额外卡组或双方重洗手卡抽卡的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：仪式·融合·同调·超量·灵摆怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM),2,2)
	-- ①：上级召唤的自己怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"解放效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的影响目标过滤条件：必须是上级召唤的怪兽
function s.atktg(e,c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 连接怪兽回到额外卡组选项的过滤条件：场上或墓地中表侧表示的连接怪兽，且可以返回卡组（额外卡组）
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_LINK) and c:IsAbleToDeck()
end
-- ②效果的发动准备与目标检查（Target函数）：判断当前可选择的选项是否符合发动条件，由玩家选择要发动的效果，并设置相应操作信息与次数限制
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡中卡片的数量
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	-- 获取对方手卡中卡片的数量
	local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 检查双方场上或墓地是否存在至少1只连接怪兽可以返回额外卡组
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 检查本回合是否未选择过连接怪兽全部回到额外卡组的效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查自己是否可以抽卡或者自己手卡数量为0
	local b2=(Duel.IsPlayerCanDraw(tp) or h1==0)
		-- 检查对方是否可以抽卡或者对方手卡数量为0
		and (Duel.IsPlayerCanDraw(1-tp) or h2==0)
		-- 检查双方手卡中是否存在至少1张可以返回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,LOCATION_HAND,1,nil)
		-- 检查本回合是否未选择过双方手卡全部回到卡组抽卡的效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择要发动的效果选项（1为连接怪兽回到额外卡组，2为双方重洗手卡并抽卡）
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回到卡组"
			{b2,aux.Stringid(id,2),2})  --"抽卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 给玩家注册本回合已选择过连接怪兽全部回到额外卡组效果的标识
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取双方场上和墓地中所有满足条件的连接怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置操作信息为将获取的连接怪兽全部送回卡组（额外卡组）
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
			-- 给玩家注册本回合已选择过双方手卡全部回到卡组效果的标识
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息为将双方手卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_HAND)
		-- 设置操作信息为双方从卡组抽卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
	end
end
-- ②效果的处理（Operation函数）：根据玩家的选择，执行对应的效果处理（回到额外卡组或重洗手卡抽卡）
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取双方场上和墓地中所有的连接怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 检查涉及墓地卡片的操作是否受到王家长眠之谷的限制而无效
		if aux.NecroValleyNegateCheck(g) then return end
		-- 双方的场上·墓地的连接怪兽全部回到额外卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 获取双方手卡中的所有卡片
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
		-- 将双方手卡中所有的卡片送回卡组
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			local og=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
			-- 若自己有手卡送回卡组，则洗切自己卡组
			if og:IsExists(Card.IsControler,1,nil,tp) then Duel.ShuffleDeck(tp) end
			-- 若对方有手卡送回卡组，则洗切对方卡组
			if og:IsExists(Card.IsControler,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
			-- 中断当前效果，使之后的抽卡与返回卡组处理不视为同时进行
			Duel.BreakEffect()
			local ct1=og:FilterCount(Card.IsPreviousControler,nil,tp)
			local ct2=og:FilterCount(Card.IsPreviousControler,nil,1-tp)
			-- 双方让自身手卡全部回到卡组。那之后，双方抽出自身回去的数量。
			Duel.Draw(tp,ct1,REASON_EFFECT)
			-- 双方让自身手卡全部回到卡组。那之后，双方抽出自身回去的数量。
			Duel.Draw(1-tp,ct2,REASON_EFFECT)
		end
	end
end
