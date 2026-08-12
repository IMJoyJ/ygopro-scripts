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
	-- 设置效果目标为场上的「水晶机巧」怪兽
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
		-- 当有同调召唤成功的「水晶机巧」怪兽时，记录该玩家在本回合同调召唤的「水晶机巧」怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c3576031.checkop)
		-- 将效果注册到全局环境，使该效果在满足条件时触发
		Duel.RegisterEffect(ge1,0)
		-- 在抽卡阶段开始时，将记录的同调召唤数量清零
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c3576031.clearop)
		-- 将效果注册到全局环境，使该效果在满足条件时触发
		Duel.RegisterEffect(ge2,0)
	end
end
-- 遍历所有特殊召唤成功的怪兽，若为「水晶机巧」同调怪兽则增加对应玩家的计数
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
-- 将全局计数器清零，用于下个回合的统计
function c3576031.clearop(e,tp,eg,ep,ev,re,r,rp)
	c3576031[0]=0
	c3576031[1]=0
end
-- 判断当前玩家在本回合是否有同调召唤的「水晶机巧」怪兽
function c3576031.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c3576031[tp]>0
end
-- 设置效果发动时的抽卡操作信息
function c3576031.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽相应数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c3576031[tp]) end
	-- 设置抽卡效果的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c3576031[tp])
end
-- 执行抽卡效果
function c3576031.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽相应数量的卡
	Duel.Draw(tp,c3576031[tp],REASON_EFFECT)
end
