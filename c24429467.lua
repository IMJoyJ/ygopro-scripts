--魔導変換
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，每次对方怪兽的效果发动，给这张卡放置1个魔力指示物。
-- ②：把有魔力指示物6个以上放置的这张卡送去墓地才能发动。从卡组把1张魔法卡加入手卡。
function c24429467.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，每次对方怪兽的效果发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 在效果发动时记录这张卡在魔法与陷阱区域存在，供后续放置魔力指示物的处理确认
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- 只要这张卡在魔法与陷阱区域存在，每次对方怪兽的效果发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c24429467.acop)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：把有魔力指示物6个以上放置的这张卡送去墓地才能发动。从卡组把1张魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,24429467)
	e4:SetCondition(c24429467.thcon)
	e4:SetCost(c24429467.thcost)
	e4:SetTarget(c24429467.thtg)
	e4:SetOperation(c24429467.thop)
	c:RegisterEffect(e4)
end
c24429467.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若发动的效果是对方的怪兽效果，且发动时这张卡在魔法与陷阱区域存在，则给这张卡放置1个魔力指示物
function c24429467.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该连锁效果的发动者玩家
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER)
	local c=e:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and p~=tp and c:GetFlagEffect(FLAG_ID_CHAINING)>0 then
		c:AddCounter(0x1,1)
	end
end
-- ②效果的发动条件：这张卡放置有6个以上的魔力指示物
function c24429467.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)>=6
end
-- ②效果的发动代价：把这张卡送去墓地
function c24429467.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价把这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：可以加入手卡的魔法卡
function c24429467.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的目标确认：卡组存在可以加入手卡的魔法卡，并设置检索及加入手卡的操作信息
function c24429467.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己卡组存在至少1张可以加入手卡的魔法卡，否则不能发动
	if chk==0 then return Duel.IsExistingMatchingCard(c24429467.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1张魔法卡加入手卡，并给对方玩家确认
function c24429467.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张可以加入手卡的魔法卡
	local g=Duel.SelectMatchingCard(tp,c24429467.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的魔法卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
