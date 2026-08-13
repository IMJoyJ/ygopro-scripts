--波動キャノン
-- 效果：
-- ①：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。给与对方这张卡的发动后经过的自己准备阶段次数×1000伤害。
function c38992735.initial_effect(c)
	-- 这张卡的发动后经过的自己准备阶段次数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38992735.reset)
	c:RegisterEffect(e1)
	-- ①：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。给与对方这张卡的发动后经过的自己准备阶段次数×1000伤害。
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
	-- 经过的自己准备阶段次数
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c38992735.turncount)
	c:RegisterEffect(e3)
end
-- 在自己准备阶段开始时，若这张卡仍在魔法与陷阱区域表侧表示存在，则将其回合计数器加1，用来累计这张卡发动后经过的准备阶段次数。
function c38992735.turncount(e,tp,eg,ep,ev,re,r,rp)
	-- 仅当当前回合玩家是这张卡的控制者（即自己的准备阶段）时才继续，避免在对方准备阶段累计计数。
	if tp~=Duel.GetTurnPlayer() then return end
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
end
-- 这张卡发动成功时，将其回合计数器重置为0，确立“这张卡发动后经过的自己准备阶段次数”从零开始计算。
function c38992735.reset(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
end
-- 发动伤害效果前的代价处理：检查这张卡能否作为代价从魔法与陷阱区域送去墓地，若能则执行代价；否则不能发动。
function c38992735.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以“代价”原因将这张卡从魔法与陷阱区域送去墓地，支付“把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动”这一代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动时确认这张卡的回合计数器大于0（即至少经过了一次自己准备阶段），然后计算伤害值为计数器×1000，将对方玩家设为效果对象并登记预定的伤害信息。
function c38992735.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetTurnCounter()>0 end
	local dam=c:GetTurnCounter()*1000
	-- 把当前连锁的对象玩家设置为对方玩家（1-tp），声明这次伤害的对象是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 把当前连锁的参数设置为要给予的伤害数值dam，供效果处理时取出。
	Duel.SetTargetParam(dam)
	-- 登记本次效果将造成伤害：目标玩家为对方，预定伤害量为dam；因为没有确定卡片对象，所以targets传入nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理阶段：从连锁信息中取出之前设置的对象玩家和伤害参数，实际给对方造成相应伤害。
function c38992735.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家p和伤害数值d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以“效果”为原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
