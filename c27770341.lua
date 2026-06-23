--超再生能力
-- 效果：
-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
function c27770341.initial_effect(c)
	-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetOperation(c27770341.activate)
	c:RegisterEffect(e1)
	if c27770341.counter==nil then
		c27770341.counter=true
		c27770341[0]=0
		c27770341[1]=0
		-- 这张卡发动时，将效果注册到场上
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(c27770341.resetcount)
		-- 将效果e2注册给玩家0，用于在抽卡阶段开始时重置计数器
		Duel.RegisterEffect(e2,0)
		-- 当有怪兽被解放时，统计该怪兽是否为龙族且来自手卡或场上
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_RELEASE)
		e3:SetOperation(c27770341.addcount)
		-- 将效果e3注册给玩家0，用于监听解放事件
		Duel.RegisterEffect(e3,0)
		-- 当有怪兽被丢弃时，统计该怪兽是否为龙族且来自手卡
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_DISCARD)
		e4:SetOperation(c27770341.addcount)
		-- 将效果e4注册给玩家0，用于监听丢弃事件
		Duel.RegisterEffect(e4,0)
	end
end
-- 在抽卡阶段开始时，将计数器清零
function c27770341.resetcount(e,tp,eg,ep,ev,re,r,rp)
	c27770341[0]=0
	c27770341[1]=0
end
-- 遍历被解放或丢弃的卡，若为龙族怪兽则增加对应玩家的计数
function c27770341.addcount(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:GetPreviousRaceOnField()==RACE_DRAGON
			or tc:IsPreviousLocation(LOCATION_HAND) and tc:IsType(TYPE_MONSTER) and tc:GetOriginalRace()==RACE_DRAGON then
			local p=tc:GetPreviousControler()
			c27770341[p]=c27770341[p]+1
		end
		tc=eg:GetNext()
	end
end
-- 在结束阶段时，注册一个效果用于抽卡
function c27770341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段时，注册一个效果用于抽卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c27770341.droperation)
	-- 将效果e1注册给玩家tp，用于在结束阶段时触发抽卡
	Duel.RegisterEffect(e1,tp)
end
-- 执行抽卡操作，抽卡数量为当前玩家的计数
function c27770341.droperation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示“对方宣言了：...”卡片27770341的发动动画
	Duel.Hint(HINT_CARD,0,27770341)
	-- 让玩家tp以效果原因抽c27770341[tp]张卡
	Duel.Draw(tp,c27770341[tp],REASON_EFFECT)
end
