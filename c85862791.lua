--泥仕合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己以及对方场上的卡同时被战斗·效果破坏的场合才能发动。双方玩家各自从卡组抽2张。
function c85862791.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己以及对方场上的卡同时被战斗·效果破坏的场合才能发动。双方玩家各自从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+85862791)
	e1:SetCountLimit(1,85862791+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c85862791.condition)
	e1:SetTarget(c85862791.target)
	e1:SetOperation(c85862791.activate)
	c:RegisterEffect(e1)
	if not c85862791.global_check then
		c85862791.global_check=true
		-- ①：自己以及对方场上的卡同时被战斗·效果破坏的场合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c85862791.regcon)
		ge1:SetOperation(c85862791.regop)
		-- 将用于监听卡片破坏事件的全局效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤出因战斗或效果破坏的、原本存在于某玩家场上的卡片
function c85862791.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局破坏事件的条件判断，检查并记录是否同时有双方场上的卡被破坏
function c85862791.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c85862791.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c85862791.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局破坏事件的处理，触发自定义事件并传递破坏方信息
function c85862791.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，将破坏的卡片组和破坏方信息（Label值）作为参数传递
	Duel.RaiseEvent(eg,EVENT_CUSTOM+85862791,re,r,rp,ep,e:GetLabel())
end
-- 效果发动的条件，检查自定义事件的参数是否为双方（PLAYER_ALL），即双方场上的卡是否同时被破坏
function c85862791.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==PLAYER_ALL
end
-- 效果发动的目标检查与操作信息设置，确认双方玩家是否都能抽卡并设置抽卡信息
function c85862791.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查双方玩家是否都具有从卡组抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 设置当前连锁的操作信息为双方玩家各抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,2)
end
-- 效果处理的执行函数，使双方玩家各自从卡组抽2张卡
function c85862791.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动效果的玩家（自己）因效果抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
	-- 让发动效果玩家的对手（对方）因效果抽2张卡
	Duel.Draw(1-tp,2,REASON_EFFECT)
end
