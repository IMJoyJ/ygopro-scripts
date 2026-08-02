--シグナル・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：每次双方的准备阶段发动。给这张卡以及场地区域的表侧表示的卡全部各放置1个信号指示物。
-- ②：有信号指示物放置的这张卡不会被战斗以及对方的效果破坏。
-- ③：1回合1次，可以把自己·对方场上的信号指示物的以下数量取除，那个效果发动。
-- ●4：给与对方800伤害。
-- ●7：自己从卡组抽1张。
-- ●10：选场上1张卡破坏。
function c9634146.initial_effect(c)
	c:EnableReviveLimit()
	-- 为信号战士添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：每次双方的准备阶段发动。给这张卡以及场地区域的表侧表示的卡全部各放置1个信号指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9634146,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c9634146.ctop)
	c:RegisterEffect(e1)
	-- ②：有信号指示物放置的这张卡不会被战斗
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c9634146.incon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 以及对方的效果破坏。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以把自己·对方场上的信号指示物的以下数量取除，那个效果发动。●4：给与对方800伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetDescription(aux.Stringid(9634146,1))  --"4：给与对方800伤害。"
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c9634146.ctcost(4))
	e4:SetTarget(c9634146.damtg)
	e4:SetOperation(c9634146.damop)
	c:RegisterEffect(e4)
	-- ●7：自己从卡组抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetDescription(aux.Stringid(9634146,2))  --"7：自己从卡组抽1张。"
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c9634146.ctcost(7))
	e5:SetTarget(c9634146.drtg)
	e5:SetOperation(c9634146.drop)
	c:RegisterEffect(e5)
	-- ●10：选场上1张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetDescription(aux.Stringid(9634146,3))  --"10：选场上1张卡破坏。"
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e6:SetCost(c9634146.ctcost(10))
	e6:SetTarget(c9634146.destg)
	e6:SetOperation(c9634146.desop)
	c:RegisterEffect(e6)
end
c9634146.mentioned_counter={
	[0x104d]=true,
}
-- 执行处理阶段：给这张卡以及场地区域的表侧表示的卡放置指示物
function c9634146.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场地区域的卡作为卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 遍历卡片组中的卡
	for tc in aux.Next(g) do
		if tc:IsCanAddCounter(0x104d,1) then
			tc:AddCounter(0x104d,1)
		end
	end
end
-- 判断这张卡上是否有指示物
function c9634146.incon(e)
	return e:GetHandler():GetCounter(0x104d)>0
end
-- 声明移除指示物的Cost函数
function c9634146.ctcost(ct)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		-- 检查是否能移除所需数量的指示物
		if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x104d,ct,REASON_COST) end
		-- 向对方玩家提示选择发动了什么效果
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		-- 移除所需数量的指示物作为发动的Cost
		Duel.RemoveCounter(tp,1,1,0x104d,ct,REASON_COST)
	end
end
-- 判断是否有符合条件的对象，并设置操作信息
function c9634146.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前正在处理的连锁的对象玩家设置成对方
	Duel.SetTargetPlayer(1-tp)
	-- 把当前正在处理的连锁的对象参数设置成800
	Duel.SetTargetParam(800)
	-- 设置操作信息：包含伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行处理阶段：给与对方伤害
function c9634146.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否有符合条件的对象，并设置操作信息
function c9634146.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 把当前正在处理的连锁的对象玩家设置成自己
	Duel.SetTargetPlayer(tp)
	-- 把当前正在处理的连锁的对象参数设置成1
	Duel.SetTargetParam(1)
	-- 设置操作信息：包含抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行处理阶段：自己抽卡
function c9634146.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断是否有符合条件的对象，并设置操作信息
function c9634146.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的卡作为卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：包含破坏效果，对象为场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行处理阶段：破坏选择的卡
function c9634146.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 手动为选择的卡显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选择的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
