--ドロール＆ロックバード
-- 效果：
-- ①：自己·对方回合，对方在抽卡阶段以外从卡组把卡加入手卡的场合，把这张卡从手卡送去墓地才能发动。这个回合，双方不能从卡组把卡加入手卡。
function c94145021.initial_effect(c)
	-- ①：自己·对方回合，对方在抽卡阶段以外从卡组把卡加入手卡的场合，把这张卡从手卡送去墓地才能发动。这个回合，双方不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94145021,0))  --"检索限制"
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CUSTOM+94145021)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94145021.condition)
	e1:SetCost(c94145021.cost)
	e1:SetOperation(c94145021.operation)
	c:RegisterEffect(e1)
	if not c94145021.global_check then
		c94145021.global_check=true
		-- 对方在抽卡阶段以外从卡组把卡加入手卡的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetCondition(c94145021.regcon)
		ge1:SetOperation(c94145021.regop)
		-- 注册全局环境效果，用于在后台监控卡片加入手牌的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：判断卡片是否是从卡组加入到指定玩家的手牌
function c94145021.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 全局效果条件：检查是否在抽卡阶段以外有玩家从卡组将卡加入手牌，并用Label记录是哪方玩家（或双方）
function c94145021.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果在抽卡阶段（或未开始阶段），则不触发效果
	if Duel.GetCurrentPhase()==PHASE_DRAW or Duel.GetCurrentPhase()==0 then return false end
	local v=0
	if eg:IsExists(c94145021.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c94145021.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局效果操作：触发自定义事件，将加入手牌的玩家信息作为参数传递
function c94145021.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知系统有玩家在抽卡阶段以外从卡组将卡加入手牌
	Duel.RaiseEvent(eg,EVENT_CUSTOM+94145021,re,r,rp,ep,e:GetLabel())
end
-- 发动条件：触发加入手牌事件的玩家必须是对方玩家（或者是双方同时加入手牌）
function c94145021.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==1-tp or ev==PLAYER_ALL
end
-- 发动代价：把这张卡从手卡送去墓地
function c94145021.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手牌中的这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动效果：使“这个回合，双方不能从卡组把卡加入手卡”的效果适用（包括检索和抽卡）
function c94145021.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，双方不能从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设置限制对象为卡组的卡片（即不能从卡组加入手牌）
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制双方玩家不能将卡组的卡加入手牌的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个回合，双方不能从卡组把卡加入手卡。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_DRAW)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,1)
	-- 注册限制双方玩家不能抽卡的效果
	Duel.RegisterEffect(e2,tp)
end
