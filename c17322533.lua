--一点着地
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：只让怪兽1只特殊召唤的场合，若那是从自己或对方的手卡往自己场上的特殊召唤则能发动。自己抽1张。
-- ②：自己回合没因这张卡的①的效果抽卡的场合，那个回合的结束阶段这张卡送去墓地。
function c17322533.initial_effect(c)
	-- 启用不入连锁的自身送墓检查全局标记，使②效果在满足条件时可在结束阶段不入连锁自动送去墓地。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：只让怪兽1只特殊召唤的场合，若那是从自己或对方的手卡往自己场上的特殊召唤则能发动。自己抽1张。
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
-- 判定特殊召唤的怪兽是否曾位于手牌且当前控制者为发动者自己，即是从手牌特殊召唤到自己场上。
function c17322533.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 特殊召唤成功的怪兽集合中存在至少1只满足从手牌特殊召唤到自己场上的怪兽，且本次特殊召唤的怪兽数量恰好为1只。
function c17322533.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17322533.filter,1,nil,tp) and #eg==1
end
-- 发动时的目标设定与操作登记：指定抽卡玩家为自己，抽卡张数为1，并登记抽卡类操作信息供规则检测。
function c17322533.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己可以抽1张卡，不能抽则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设为发动者自己，表示抽卡对象为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡操作信息：分类为抽卡、无对象卡、预计抽1张、对象玩家为自己，供相关卡的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：按设定的玩家与张数执行抽卡；若实际抽卡成功，则给此卡登记17322533标记，用于②效果判断本回合是否已抽卡。
function c17322533.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因执行抽卡，并判断是否实际抽到了卡（返回非0表示成功）。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		e:GetHandler():RegisterFlagEffect(17322533,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,0,1)
	end
end
-- ②效果的发动条件判断：当前是此卡控制者的回合，且此卡没有17322533标记，即本回合未用①效果抽到过卡。
function c17322533.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	-- 返回条件：当前回合玩家等于此卡控制者且此卡无17322533标记，满足则执行送墓。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(17322533)==0
end
-- ②效果处理操作：将这张卡自身送去墓地。
function c17322533.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡自身送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
