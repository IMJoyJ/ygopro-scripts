--おジャマ・ピンク
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从手卡·场上送去墓地的场合才能发动。双方玩家从卡组抽1张，那之后选1张手卡丢弃。这个效果让自己把「扰乱」卡丢弃的场合，可以再指定没有使用的对方的怪兽区域1处。那个区域直到对方回合结束时不能使用。
function c42517468.initial_effect(c)
	-- 创建一张诱发选发效果，用于处理卡牌从手牌或场上送去墓地时的连锁效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42517468,1))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,42517468)
	e1:SetCondition(c42517468.thcon)
	e1:SetTarget(c42517468.target)
	e1:SetOperation(c42517468.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡从手卡或场上送去墓地时
function c42517468.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 效果的处理目标：双方各抽一张卡，然后各丢弃一张手卡
function c42517468.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以进行抽卡操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置操作信息：双方各丢弃一张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	-- 设置操作信息：双方各抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果的处理流程：双方各抽一张卡，若有人抽卡成功则中断效果处理，然后各自丢弃一张手卡，若丢弃的是扰乱卡则可选择让对方怪兽区域不能使用
function c42517468.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家从卡组抽一张卡
	local h1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家从卡组抽一张卡
	local h2=Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 如果任意一方成功抽卡，则中断当前效果处理
	if h1>0 or h2>0 then Duel.BreakEffect() end
	local groundcollapse=false
	if h1>0 then
		-- 将当前玩家的手卡洗切
		Duel.ShuffleHand(tp)
		-- 当前玩家丢弃一张手卡
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		-- 获取刚刚丢弃的卡片
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsSetCard(0xf) then groundcollapse=true end
	end
	if h2>0 then
		-- 将对方玩家的手卡洗切
		Duel.ShuffleHand(1-tp)
		-- 对方玩家丢弃一张手卡
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	-- 判断是否满足触发额外效果的条件：丢弃的是扰乱卡且对方有可用怪兽区域
	if groundcollapse and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择让对方怪兽区域不能使用
		and Duel.SelectYesNo(tp,aux.Stringid(42517468,0)) then  --"是否指定对方怪兽区域不能使用？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 选择对方一个可用的怪兽区域使其不能使用
		local zone=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		if tp==1 then
			zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
		end
		-- 创建一个无效区域效果，使指定区域在对方回合结束前不能使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetValue(zone)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 将创建的无效区域效果注册给全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
