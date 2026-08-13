--クリスタルP
-- 效果：
-- ①：自己场上的「水晶机巧」怪兽的攻击力·守备力上升300。
-- ②：自己·对方的结束阶段才能发动。自己从卡组抽出这个回合自己同调召唤的「水晶机巧」同调怪兽的数量。
function c3576031.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「水晶机巧」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(300)
	-- 指定该攻击力上升效果只对自己场上表侧表示存在的「水晶机巧」系列怪兽（字段0xea）适用。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xea))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己·对方的结束阶段才能发动。自己从卡组抽出这个回合自己同调召唤的「水晶机巧」同调怪兽的数量。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3576031,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c3576031.drcon)
	e4:SetTarget(c3576031.drtg)
	e4:SetOperation(c3576031.drop)
	c:RegisterEffect(e4)
	if not c3576031.global_check then
		c3576031.global_check=true
		c3576031[0]=0
		c3576031[1]=0
		-- 自己同调召唤的「水晶机巧」同调怪兽的数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c3576031.checkop)
		-- 将计数用全场效果ge1注册到全局，当任意特殊召唤成功时自动触发，用于累计场上出现的「水晶机巧」同调召唤数量。
		Duel.RegisterEffect(ge1,0)
		-- 自己从卡组抽出这个回合自己同调召唤的「水晶机巧」同调怪兽的数量。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c3576031.clearop)
		-- 将重置用全场效果ge2注册到全局，在抽卡阶段开始时清空双方的「水晶机巧」同调召唤计数，实现“这个回合”的时间限定。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 遍历特殊召唤成功的怪兽组，若为「水晶机巧」系列且为同调召唤，则给对应召唤玩家的计数器加1。
function c3576031.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSetCard(0xea) and tc:IsSummonType(SUMMON_TYPE_SYNCHRO) then
			local p=tc:GetSummonPlayer()
			c3576031[p]=c3576031[p]+1
		end
		tc=eg:GetNext()
	end
end
-- 在抽卡阶段开始时将玩家0和玩家1的计数清零，保证只统计当前回合的同调召唤数量。
function c3576031.clearop(e,tp,eg,ep,ev,re,r,rp)
	c3576031[0]=0
	c3576031[1]=0
end
-- 发动条件判断：当前玩家tp的本回合「水晶机巧」同调召唤计数大于0时才允许发动。
function c3576031.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c3576031[tp]>0
end
-- 效果发动合法性和操作信息设定：检查tp能否抽对应数量卡，并设置抽卡的操作信息。
function c3576031.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查玩家tp是否有能力抽 c3576031[tp] 张卡（即不能抽卡时不能发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c3576031[tp]) end
	-- 设置本次抽卡操作的信息：抽卡类别、目标玩家tp、抽卡数量为c3576031[tp]，供连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c3576031[tp])
end
-- 效果处理时执行抽卡：让当前回合玩家tp抽取记录的数量的卡。
function c3576031.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行抽卡：玩家tp以效果原因抽取 c3576031[tp] 张卡。
	Duel.Draw(tp,c3576031[tp],REASON_EFFECT)
end
