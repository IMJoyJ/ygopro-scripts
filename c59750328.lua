--命削りの宝札
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。
-- ①：自己直到手卡变成3张为止从卡组抽卡。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。这个回合的结束阶段，自己手卡全部送去墓地。
local s,id,o=GetID()
-- 注册卡片发动时的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。①：自己直到手卡变成3张为止从卡组抽卡。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。这个回合的结束阶段，自己手卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：检查并注册本回合不能特殊召唤的限制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查本回合自己是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤。①：自己直到手卡变成3张为止从卡组抽卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册本回合不能特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动的准备：检查是否能抽卡并设置抽卡数量
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算直到手卡变成3张为止需要抽卡的数量（排除正在发动的这张卡）
	local ct=3-Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND,0,e:GetHandler())
	-- 在发动时检查是否需要抽卡且玩家是否可以抽卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡操作的信息，包括抽卡数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：执行抽卡，并注册伤害变0和结束阶段丢弃手卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算当前手卡数量与3张的差值，确定实际需要抽卡的数量
	local ct=3-Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ct>0 then
		-- 让目标玩家因效果抽卡
		Duel.Draw(p,ct,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使对方受到的全部伤害变成0的效果
		Duel.RegisterEffect(e1,p)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使对方受到的效果伤害变成0的辅助效果
		Duel.RegisterEffect(e2,p)
	end
	-- 这个回合的结束阶段，自己手卡全部送去墓地。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetOperation(s.tgop)
	-- 注册在回合结束阶段触发的延迟效果
	Duel.RegisterEffect(e3,p)
end
-- 结束阶段将手卡全部送去墓地的效果处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段显示该卡的效果发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 获取玩家当前手卡中的所有卡片
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	-- 将获取到的全部手卡因效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
