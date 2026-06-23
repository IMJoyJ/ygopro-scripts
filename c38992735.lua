--波動キャノン
-- 效果：
-- ①：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。给与对方这张卡的发动后经过的自己准备阶段次数×1000伤害。
function c38992735.initial_effect(c)
	-- ①：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38992735.reset)
	c:RegisterEffect(e1)
	-- 给与对方这张卡的发动后经过的自己准备阶段次数×1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38992735,0))  --"给对方这张卡发动后经过的自己的准备阶段数*1000的伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c38992735.cost)
	e2:SetTarget(c38992735.tg)
	e2:SetOperation(c38992735.op)
	c:RegisterEffect(e2)
	-- 设置一个场地区域持续效果，用于记录准备阶段次数
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c38992735.turncount)
	c:RegisterEffect(e3)
end
-- 当准备阶段开始时，若当前玩家为回合玩家，则将计数器加一
function c38992735.turncount(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前处理的玩家是否为回合玩家，若不是则不执行计数器增加
	if tp~=Duel.GetTurnPlayer() then return end
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
end
-- 重置计数器为0，用于初始化
function c38992735.reset(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
end
-- 支付将此卡送入墓地的代价
function c38992735.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置伤害效果的目标玩家和伤害值
function c38992735.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetTurnCounter()>0 end
	local dam=c:GetTurnCounter()*1000
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁效果的操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对目标玩家造成指定伤害
function c38992735.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
