--魔法族の結界
-- 效果：
-- ①：每次场上的表侧表示的魔法师族怪兽被破坏给这张卡放置1个魔力指示物（最多4个）。
-- ②：把有魔力指示物放置的这张卡和自己场上1只表侧表示的魔法师族怪兽送去墓地才能发动。自己从卡组抽出这张卡放置的魔力指示物的数量。
function c17896384.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,4)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次场上的表侧表示的魔法师族怪兽被破坏给这张卡放置1个魔力指示物（最多4个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c17896384.ctcon)
	e2:SetOperation(c17896384.ctop)
	c:RegisterEffect(e2)
	-- ②：把有魔力指示物放置的这张卡和自己场上1只表侧表示的魔法师族怪兽送去墓地才能发动。自己从卡组抽出这张卡放置的魔力指示物的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17896384,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c17896384.drcost)
	e3:SetTarget(c17896384.drtg)
	e3:SetOperation(c17896384.drop)
	c:RegisterEffect(e3)
end
c17896384.mentioned_counter={
	[0x1]=true,
}
-- 过滤函数，用于判断被破坏的怪兽是否为场上的表侧表示的魔法师族怪兽。
function c17896384.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_SPELLCASTER)~=0
end
-- 条件函数，检查是否有满足条件的怪兽被破坏。
function c17896384.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17896384.ctfilter,1,nil)
end
-- 操作函数，当有符合条件的怪兽被破坏时，给这张卡放置1个魔力指示物。
function c17896384.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 过滤函数，用于选择场上正面表示的魔法师族怪兽作为发动效果的对象。
function c17896384.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost()
end
-- 费用函数，检查是否满足发动条件：将此卡和1只场上的魔法师族怪兽送去墓地。
function c17896384.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 费用函数，检查是否满足发动条件：将此卡和1只场上的魔法师族怪兽送去墓地。
		and Duel.IsExistingMatchingCard(c17896384.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	e:SetLabel(e:GetHandler():GetCounter(0x1))
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上符合条件的魔法师族怪兽作为效果的支付对象。
	local g=Duel.SelectMatchingCard(tp,c17896384.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的卡送去墓地作为发动效果的费用。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数，设置效果的目标为当前玩家，并设定抽卡数量。
function c17896384.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)>0 end
	-- 设置效果的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为魔力指示物的数量。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果的操作信息为抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 操作函数，根据设定的参数执行抽卡效果。
function c17896384.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行从卡组抽指定数量卡牌的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
