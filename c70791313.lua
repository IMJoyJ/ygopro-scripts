--王立魔法図書館
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把这张卡3个魔力指示物取除才能发动。自己从卡组抽1张。
function c70791313.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 创建效果e0，并设置其类型为持续/场上效果，不可被无效化，触发时机为连锁发生时，生效范围为主怪兽区，操作为调用aux.chainreg函数。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 该行代码在规则层面用于记录连锁发生时这张卡在场上存在，以便后续的指示物计数。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 创建效果e1，并设置其类型为持续/场上效果，触发时机为连锁处理结束时，生效范围为主怪兽区，操作为调用c70791313.acop函数。
-- 相关子函数：
-- c70791313.acop: 如果连锁卡片是魔法卡且王立魔法图书馆的FLAG_ID_CHAINING标志大于0，则给王立魔法图书馆增加一个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c70791313.acop)
	c:RegisterEffect(e1)
	-- 创建效果e2，并设置其描述为“抽卡”，类别为抽卡效果，类型为起动效果，生效范围为主怪兽区，具有玩家对象特性，设定费用为c70791313.drcost函数，目标选择为c70791313.drtg函数，操作为c70791313.drop函数。
-- 相关子函数：
-- c70791313.drcost: 如果检查标志为0，则返回王立魔法图书馆是否可以移除3个魔力指示物作为费用；否则，移除3个魔力指示物作为费用。
-- c70791313.drtg: 如果检查标志为0，则返回玩家是否可以抽一张卡；否则，设置目标玩家为当前回合玩家，设置目标参数为1，设置操作信息为抽卡效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70791313,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCost(c70791313.drcost)
	e2:SetTarget(c70791313.drtg)
	e2:SetOperation(c70791313.drop)
	c:RegisterEffect(e2)
end
c70791313.mentioned_counter={
	[0x1]=true,
}
-- 该函数用于在魔法卡发动时给王立魔法图书馆增加魔力指示物。它首先检查连锁卡片是否是魔法卡并且王立魔法图书馆的FLAG_ID_CHAINING标志大于0，如果是，则给王立魔法图书馆增加一个魔力指示物。
function c70791313.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 该函数用于处理移除魔力指示物的费用。如果检查标志为0，则检查王立魔法图书馆是否可以移除3个魔力指示物作为费用并返回结果；否则，移除3个魔力指示物作为费用。
function c70791313.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 该函数用于确定抽卡的目标玩家和参数。如果检查标志为0，则检查当前回合玩家是否可以抽一张卡并返回结果；否则，设置目标玩家为当前回合玩家，设置目标参数为1，设置操作信息为抽卡效果。
function c70791313.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合玩家是否可以抽一张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前正在处理的连锁的对象玩家设置为当前回合玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前正在处理的连锁的对象参数设置为1。
	Duel.SetTargetParam(1)
	-- 设置当前处理的连锁的操作信息，类别为抽卡，目标玩家为tp，目标参数为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 该函数用于执行抽卡操作。它首先从连锁信息中获取目标玩家和抽卡数量，然后调用Duel.Draw函数让目标玩家以效果原因抽取指定数量的卡片。
function c70791313.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家p以效果REASON_EFFECT抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
