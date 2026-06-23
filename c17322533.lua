--一点着地
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：只让怪兽1只特殊召唤的场合，若那是从自己或对方的手卡往自己场上的特殊召唤则能发动。自己抽1张。
-- ②：自己回合没因这张卡的①的效果抽卡的场合，那个回合的结束阶段这张卡送去墓地。
function c17322533.initial_effect(c)
	-- 启用全局标记，用于检测自身送入墓地的场合
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只让怪兽1只特殊召唤的场合，若那是从自己或对方的手卡往自己场上的特殊召唤则能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17322533,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,17322533)
	e2:SetCondition(c17322533.condition)
	e2:SetTarget(c17322533.target)
	e2:SetOperation(c17322533.operation)
	c:RegisterEffect(e2)
	-- ②：自己回合没因这张卡的①的效果抽卡的场合，那个回合的结束阶段这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c17322533.tgcon)
	e3:SetOperation(c17322533.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查特殊召唤的怪兽是否来自手牌
function c17322533.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 效果条件：确认特殊召唤的怪兽来自手牌且只召唤了一只
function c17322533.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17322533.filter,1,nil,tp) and #eg==1
end
-- 效果目标：判断玩家是否可以抽卡并设置抽卡目标
function c17322533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡的数量参数
	Duel.SetTargetParam(1)
	-- 设置效果操作信息，指定抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡并记录抽卡标志
function c17322533.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作并判断是否成功
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		e:GetHandler():RegisterFlagEffect(17322533,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,0,1)
	end
end
-- 结束阶段条件判断：判断是否为己方回合且未抽卡
function c17322533.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	-- 判断是否为己方回合且未因①效果抽卡
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(17322533)==0
end
-- 效果处理：将自身送去墓地
function c17322533.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身以效果原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
