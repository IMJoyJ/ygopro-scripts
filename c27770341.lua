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
		-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(c27770341.resetcount)
		-- 将抽卡阶段开始时的重置计数效果注册到全局，使每个回合的抽卡阶段开始时将双方已记录的丢弃·解放龙族怪兽数量清零。
		Duel.RegisterEffect(e2,0)
		-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_RELEASE)
		e3:SetOperation(c27770341.addcount)
		-- 将解放怪兽时的计数效果注册到全局，场上龙族怪兽被解放时记录其原控制者对应计数。
		Duel.RegisterEffect(e3,0)
		-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e4:SetCode(EVENT_DISCARD)
		e4:SetOperation(c27770341.addcount)
		-- 将手卡被丢弃时的计数效果注册到全局，手卡中的龙族怪兽被丢弃时记录其原持有者/控制者（即丢弃前的控制者）对应计数。
		Duel.RegisterEffect(e4,0)
	end
end
-- 重置函数：在每个抽卡阶段开始时，把双方（玩家0和玩家1）累计的龙族丢弃/解放计数归零，以记录新回合的发生次数。
function c27770341.resetcount(e,tp,eg,ep,ev,re,r,rp)
	c27770341[0]=0
	c27770341[1]=0
end
-- 计数函数：遍历事件组中的卡，若为从场上解放且解放前种族为龙族，或从手卡丢弃且为龙族怪兽，则将该卡之前控制者对应的计数加1。
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
-- 发动时的处理函数：在本回合结束阶段注册一个一次性处理效果，用于结算抽卡；该效果在结束阶段时触发并只发动一次。
function c27770341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡发动的回合的结束阶段，自己从卡组抽出这个回合从自己手卡丢弃的龙族怪兽以及这个回合从自己的手卡·场上解放的龙族怪兽的数量。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c27770341.droperation)
	-- 将结束阶段触发的一次性抽卡效果注册给发动玩家tp，使该玩家在结束阶段执行抽卡操作。
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段抽卡处理函数：向双方展示这张卡，然后让发动玩家抽出本回合累计的龙族怪兽丢弃/解放数量的卡。
function c27770341.droperation(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示卡号为27770341的卡片（超再生能力），提示该效果正在结算。
	Duel.Hint(HINT_CARD,0,27770341)
	-- 让发动玩家tp以效果原因抽出c27770341[tp]（该玩家本回合累计的丢弃·解放龙族怪兽数量）张卡。
	Duel.Draw(tp,c27770341[tp],REASON_EFFECT)
end
