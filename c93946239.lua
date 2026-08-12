--無の煉獄
-- 效果：
-- 自己手卡是3张以上的场合才能发动。从自己卡组抽1张卡，这个回合的结束阶段时自己手卡全部丢弃。
local s,id,o=GetID()
-- 注册这张卡的发动效果
function s.initial_effect(c)
	-- 自己手卡是3张以上的场合才能发动。从自己卡组抽1张卡，这个回合的结束阶段时自己手卡全部丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_SELF)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己手卡数量是否在3张以上
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数量是否大于2张（即3张以上）
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>2
end
-- 效果发动的目标处理，检查是否能抽卡并设置抽卡参数与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数，执行抽卡并注册回合结束时丢弃手卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 这个回合的结束阶段时自己手卡全部丢弃。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.disop)
	-- 将结束阶段丢弃手卡的效果注册给玩家
	Duel.RegisterEffect(e1,p)
end
-- 结束阶段丢弃手卡效果的具体处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面上显示该卡片的发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 获取玩家自己的全部手卡
	local g=Duel.GetFieldGroup(e:GetOwnerPlayer(),LOCATION_HAND,0)
	-- 将全部手卡以效果丢弃的方式送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
end
