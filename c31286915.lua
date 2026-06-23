--K9-EX “Ripper／M”
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 为当前卡添加XYZ召唤手续，需要9星怪兽2只。
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- 创建并注册一个触发型效果，当这张卡用「K9」魔法·陷阱卡的效果特殊召唤时发动。①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- 创建并注册一个单发效果，使这张卡具有贯穿伤害能力。②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 创建并注册一个快速型效果，当对方发动怪兽效果时发动。③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 定义tdcon函数，作为①号效果的条件判断。如果当前卡是特殊召唤，且特殊召唤使用了0x1cb（K9魔法/陷阱卡），并且被响应的效果是魔法或陷阱卡，则返回true。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSpecialSummonSetCard(0x1cb) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义tdfilter函数，用于筛选可以送回卡组的卡片。该函数检查一张卡是否能够送入卡组。
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- 定义tdtg函数，作为①号效果的目标选择。在确认时，检查目标卡是否位于墓地或除外区，且为对方控制，并可送回卡组；在选择时，提示玩家选择要返回卡组的卡片，并将选定的卡片设置为连锁操作的目标。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 如果正在确认目标，则判断目标卡是否符合条件（墓地/除外、对方控制、可送回卡组）。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 向玩家提示“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从墓地或除外区选择1-2张卡片。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,2,nil)
	-- 设置连锁操作信息，表示当前操作是送回卡组的效果，目标为选定的卡片。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 定义tdop函数，作为①号效果的运作。将连锁的目标卡送入卡组。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的目标卡组。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将目标卡组中的卡片送回卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义discon函数，作为③号效果的条件判断。如果发动者不是当前玩家，且被响应的效果是怪兽效果，并且连锁可以被无效化，则返回true。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		-- 检查被响应的效果是否为怪兽效果，以及连锁是否可被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 定义discost函数，作为③号效果的费用。如果正在确认费用，则检查当前卡是否有足够的超量素材移除；否则，移除2个超量素材。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 定义distg函数，作为③号效果的目标选择。在确认时返回true；在选择时，获取场上所有卡片并设置为目标，同时设置操作信息为破坏和无效。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前场上的所有卡片。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，表示当前操作是破坏效果，目标为场上所有卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置连锁操作信息，表示当前操作是使效果无效，目标为被响应的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义disop函数，作为③号效果的运作。如果成功无效化对方的效果，则获取场上所有卡片并破坏它们。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效化连锁中的效果。
	if Duel.NegateEffect(ev) then
		-- 获取当前场上的所有卡片。
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果的处理流程。
			Duel.BreakEffect()
			-- 破坏目标卡组中的所有卡片。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
