--億年の氷墓
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，对方怪兽的效果用除破坏以外的方法让自己场上的怪兽从场上离开的场合，可以从以下效果选择1个发动。
-- ●这次主要阶段结束。
-- ●下次的对方回合的主要阶段1跳过。
local s,id,o=GetID()
-- 初始化卡片效果：创建并注册效果e1，e1为陷阱卡的发动效果，监听怪兽离场事件，1回合1次且为誓约次数，使用延迟触发，并设定发动条件、发动时处理和效果处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，对方怪兽的效果用除破坏以外的方法让自己场上的怪兽从场上离开的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤离场怪兽：该怪兽必须是怪兽、此前控制者为自己、离场原因不是破坏而是效果、导致离场的效果是对方怪兽的效果。
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and not c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():IsActiveType(TYPE_MONSTER)
		and c:GetReasonPlayer()==1-tp
end
-- 发动条件：当前必须是自己或对方的主要阶段1或主要阶段2，且本次离场怪兽中存在满足s.filter条件的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处阶段，用于判断是否为主要阶段1或主要阶段2。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(s.filter,1,nil,tp)
end
-- 发动时处理：效果可以发动时返回真，然后让发动者从两个选项中选择，并将选项编号存入效果的Label。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家选择“这次主要阶段结束”或“下次的对方回合的主要阶段1跳过”，返回所选选项的序号（0或1）。
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"这次主要阶段结束/下次的对方回合的主要阶段1跳过"
	e:SetLabel(op)
end
-- 效果处理：读取发动时选择的选项，若为0则调用endthism1结束本次主要阶段，若为1则调用skipnxtm1跳过对方下次主要阶段1。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		s.endthism1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.skipnxtm1(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 处理“这次主要阶段结束”：获取当前所处的主要阶段，然后跳过当前回合玩家的该阶段，使主要阶段直接结束。
function s.endthism1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的主要阶段，用于作为要跳过的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 将当前回合玩家的当前主要阶段（主要阶段1或2）直接跳过，实现“这次主要阶段结束”。
	Duel.SkipPhase(Duel.GetTurnPlayer(),ph,RESET_PHASE+ph,1)
end
-- 处理“下次的对方回合的主要阶段1跳过”：创建一个全场效果来跳过对方主要阶段1；若当前回合玩家是对方，则记录当前回合数并设置延迟条件，使效果在下一个对方回合才生效，否则直接对下个对方回合生效，并在对方回合结束阶段重置。
function s.skipnxtm1(e,tp,eg,ep,ev,re,r,rp)
	-- ●下次的对方回合的主要阶段1跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前回合玩家是否是对方（1-tp），若是，则说明现在正处于对方回合，需要让跳过效果推迟到下一个对方回合，而非影响当前回合。
	if Duel.GetTurnPlayer()==1-tp then
		-- 记录当前回合数到效果标签，供条件函数判断回合数是否已经推进，从而确保跳过效果从下一个对方回合开始适用。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN) end
	-- 将创建好的跳过对方主要阶段1的场地效果注册到场上，由当前玩家控制。
	Duel.RegisterEffect(e1,tp)
end
-- 定义跳过效果的适用条件：仅当当前回合数不等于标签记录值时，跳过对方主要阶段1的效果才生效。
function s.skipcon(e)
	-- 比较当前回合数与标签记录值是否不同，若不同则返回真，表示已进入下一回合，可以跳过对方主要阶段1。
	return Duel.GetTurnCount()~=e:GetLabel()
end
