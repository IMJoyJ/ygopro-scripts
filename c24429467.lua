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
	-- ①：只要这张卡在魔法与陷阱区域存在，每次对方怪兽的效果发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	-- 记录连锁发生时这张卡在场上存在
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ②：把有魔力指示物6个以上放置的这张卡送去墓地才能发动。从卡组把1张魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c24429467.acop)
	c:RegisterEffect(e3)
	-- 检索满足条件的卡片组、将目标怪兽特殊召唤
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
-- 当对方怪兽效果发动时，若该怪兽为怪兽类型且发动玩家不是自己，则给此卡放置1个魔力指示物
function c24429467.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动玩家
	local p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER)
	local c=e:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and p~=tp and c:GetFlagEffect(FLAG_ID_CHAINING)>0 then
		c:AddCounter(0x1,1)
	end
end
-- 判断此卡是否拥有6个以上魔力指示物
function c24429467.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x1)>=6
end
-- 支付将此卡送去墓地作为代价
function c24429467.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以效果原因将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义用于检索的过滤函数，筛选可加入手牌的魔法卡
function c24429467.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置连锁处理时的操作信息，确定要处理的卡组和数量
function c24429467.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24429467.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将一张魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索并加入手牌的效果
function c24429467.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c24429467.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
