--チキンレース
-- 效果：
-- ①：只要这张卡在场地区域存在，比对方基本分少的玩家受到的全部伤害变成0。
-- ②：双方玩家1回合1次，自己主要阶段可以支付1000基本分从以下效果选择1个发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
-- ●从卡组抽1张。
-- ●这张卡破坏。
-- ●对方回复1000基本分。
function c67616300.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，比对方基本分少的玩家受到的全部伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c67616300.damcon1)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	local e7=e2:Clone()
	e7:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e7)
	local e3=e2:Clone()
	e3:SetTargetRange(0,1)
	e3:SetCondition(c67616300.damcon2)
	c:RegisterEffect(e3)
	local e8=e3:Clone()
	e8:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e8)
	-- ②：双方玩家1回合1次，自己主要阶段可以支付1000基本分从以下效果选择1个发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。●从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67616300,0))  --"从卡组抽1张"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c67616300.effcost)
	e4:SetTarget(c67616300.drtg)
	e4:SetOperation(c67616300.drop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetDescription(aux.Stringid(67616300,1))  --"这张卡破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e5:SetTarget(c67616300.destg)
	e5:SetOperation(c67616300.desop)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetDescription(aux.Stringid(67616300,2))  --"对方回复1000基本分"
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetTarget(c67616300.rectg)
	e6:SetOperation(c67616300.recop)
	c:RegisterEffect(e6)
end
-- 判定回合玩家（自己）的LP是否比对方少
function c67616300.damcon1(e)
	local tp=e:GetHandlerPlayer()
	-- 返回自己LP是否小于对方LP的判定结果
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 判定对方的LP是否比自己少
function c67616300.damcon2(e)
	local tp=e:GetHandlerPlayer()
	-- 返回对方LP是否小于自己LP的判定结果
	return Duel.GetLP(1-tp)<Duel.GetLP(tp)
end
-- 效果发动代价（Cost）处理函数，检查并支付1000基本分，并向对方提示选择的效果
function c67616300.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
	-- 向对方玩家提示自己选择发动了哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 抽卡效果的目标（Target）处理函数，检查是否能抽卡，设置抽卡参数并限制连锁
function c67616300.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家当前是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置连锁限制，使双方不能对应这个效果的发动把任何卡的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 抽卡效果的运行（Operation）处理函数，执行抽卡
function c67616300.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 破坏效果的目标（Target）处理函数，检查自身是否可破坏，设置破坏信息并限制连锁
function c67616300.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	-- 设置当前连锁的操作信息为：破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁限制，使双方不能对应这个效果的发动把任何卡的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 破坏效果的运行（Operation）处理函数，执行破坏
function c67616300.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 回复效果的目标（Target）处理函数，设置回复参数并限制连锁
function c67616300.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的目标参数为1000（回复1000基本分）
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：对方玩家回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
	-- 设置连锁限制，使双方不能对应这个效果的发动把任何卡的效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 回复效果的运行（Operation）处理函数，执行回复
function c67616300.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
