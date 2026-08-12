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
-- 过滤条件：被破坏的卡破坏前在怪兽区域、为表侧表示且种族是魔法师族
function c17896384.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_SPELLCASTER)~=0
end
-- 触发条件：被破坏的卡中存在破坏前在场上表侧表示的魔法师族怪兽
function c17896384.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17896384.ctfilter,1,nil)
end
-- 给这张卡放置1个魔力指示物
function c17896384.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 过滤条件：自己场上表侧表示的魔法师族怪兽且能作为代价送去墓地
function c17896384.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价的确认：这张卡能作为代价送去墓地，且自己场上存在1只符合条件的表侧表示魔法师族怪兽
function c17896384.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 确认自己怪兽区域存在至少1只能作为代价送去墓地的表侧表示魔法师族怪兽
		and Duel.IsExistingMatchingCard(c17896384.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	e:SetLabel(e:GetHandler():GetCounter(0x1))
	-- 向玩家提示"请选择要送去墓地的卡"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己怪兽区域选择1只表侧表示的魔法师族怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c17896384.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 把这张卡和选择的魔法师族怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果对象设定：要求这张卡放置有魔力指示物才能发动，并将抽卡玩家和抽卡数量（这张卡放置的魔力指示物数量）记录到连锁信息中
function c17896384.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)>0 end
	-- 把效果对象玩家设定为发动玩家
	Duel.SetTargetPlayer(tp)
	-- 把效果对象参数设定为这张卡放置的魔力指示物数量（即抽卡数量）
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息：该效果为抽卡效果，预计发动玩家从卡组抽出对应数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理：从连锁信息中取出抽卡的玩家和张数，让该玩家从卡组抽卡
function c17896384.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家（抽卡的玩家）和对象参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家以效果原因抽出对应数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
