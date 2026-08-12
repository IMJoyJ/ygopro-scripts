--星遺物－『星冠』
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，③的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：从额外卡组特殊召唤的场上的怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
-- ③：通常召唤的这张卡被解放的场合才能发动。从卡组把1张「星遗物」魔法·陷阱卡加入手卡。
function c27918365.initial_effect(c)
	-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27918365,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,27918365+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c27918365.spcon)
	e1:SetValue(c27918365.spval)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的场上的怪兽的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27918365,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c27918365.negcon)
	e2:SetCost(c27918365.negcost)
	e2:SetTarget(c27918365.negtg)
	e2:SetOperation(c27918365.negop)
	c:RegisterEffect(e2)
	-- ③：通常召唤的这张卡被解放的场合才能发动。从卡组把1张「星遗物」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27918365,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,27918366)
	e3:SetCondition(c27918365.thcon)
	e3:SetTarget(c27918365.thtg)
	e3:SetOperation(c27918365.thop)
	c:RegisterEffect(e3)
end
-- 检查特殊召唤时是否满足条件：手卡中的卡是否能特殊召唤到连接区的空位上。
function c27918365.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家的连接区域。
	local zone=Duel.GetLinkedZone(tp)
	-- 判断当前玩家的连接区域是否有足够的空位用于特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的参数：返回0和连接区域。
function c27918365.spval(e,c)
	-- 返回0和连接区域，用于特殊召唤的参数设置。
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- 判断是否满足无效发动的条件：不是战斗破坏状态、发动的是怪兽效果、从额外卡组召唤、发动位置在怪兽区域、连锁可被无效。
function c27918365.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and loc==LOCATION_MZONE
		-- 判断当前连锁是否可以被无效。
		and Duel.IsChainNegatable(ev)
end
-- 设置无效发动效果的费用：解放自身。
function c27918365.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放自身作为费用。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置无效发动效果的目标信息：无效发动并可能破坏对象。
function c27918365.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效发动效果的操作：无效发动并破坏对象。
function c27918365.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动并确定对象是否可破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏连锁对象。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义检索卡牌的过滤条件：属于星遗物系列的魔法或陷阱卡且可加入手牌。
function c27918365.thfilter(c)
	return c:IsSetCard(0xfe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 判断是否满足效果发动条件：该卡是通常召唤的。
function c27918365.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 设置检索效果的目标信息：从卡组检索一张星遗物魔法或陷阱卡。
function c27918365.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件：卡组中是否存在符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c27918365.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作的信息：将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作：选择并加入手牌，确认对方查看。
function c27918365.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡牌。
	local g=Duel.SelectMatchingCard(tp,c27918365.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡牌。
		Duel.ConfirmCards(1-tp,g)
	end
end
