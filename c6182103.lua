--究極体ミュートリアス
-- 效果：
-- 8星以上的「秘异三变」怪兽×3
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：卡的效果发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张「秘异三变」卡从自己的手卡·墓地以及自己场上的表侧表示的卡之中除外才能发动。那个发动无效并除外。
-- ②：融合召唤的这张卡被对方破坏的场合才能发动。选除外的自己的「秘异三变」卡3种类（怪兽·魔法·陷阱）各最多1张加入手卡。
function c6182103.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要3只满足过滤条件（8星以上的「秘异三变」怪兽）的怪兽作为素材
	aux.AddFusionProcFunRep(c,c6182103.ffilter,3,true)
	-- ①：卡的效果发动时，把和那个效果相同种类（怪兽·魔法·陷阱）的1张「秘异三变」卡从自己的手卡·墓地以及自己场上的表侧表示的卡之中除外才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6182103,0))  --"发动无效并除外"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,6182103)
	e1:SetCondition(c6182103.negcon)
	e1:SetCost(c6182103.negcost)
	-- 设置效果1的目标处理函数为无效并除外的辅助函数
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c6182103.negop)
	c:RegisterEffect(e1)
	-- ②：融合召唤的这张卡被对方破坏的场合才能发动。选除外的自己的「秘异三变」卡3种类（怪兽·魔法·陷阱）各最多1张加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79194594,1))  --"效果免疫"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,6182104)
	e2:SetCondition(c6182103.thcon)
	e2:SetTarget(c6182103.thtg)
	e2:SetOperation(c6182103.thop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤条件：属于「秘异三变」系列且等级在8星以上的怪兽
function c6182103.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x157) and c:IsLevelAbove(8)
end
-- 效果1的发动条件：这张卡没有处于战斗破坏确定状态，且被连锁的效果的发动可以被无效
function c6182103.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查当前连锁的效果发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果1的Cost过滤条件：非战破状态、可以作为Cost除外、在场上时必须表侧表示、属于「秘异三变」系列且卡片类型与被连锁的效果相同
function c6182103.cfilter(c,rtype)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsAbleToRemoveAsCost()
		and (not c:IsOnField() or c:IsFaceup())
		and c:IsType(rtype) and c:IsSetCard(0x157)
end
-- 效果1的Cost处理：从自己的手卡、墓地以及场上表侧表示的卡中，将1张与被连锁效果相同类型的「秘异三变」卡除外
function c6182103.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=re:GetActiveType()&0x7
	-- Cost检查阶段：检查自己的手卡、墓地、场上是否存在至少1张满足条件的「秘异三变」卡可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c6182103.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,rtype) end
	-- 玩家选择1张满足条件的「秘异三变」卡
	local g=Duel.SelectMatchingCard(tp,c6182103.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,rtype)
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果1的操作处理：使被连锁的效果发动无效，并将其除外
function c6182103.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该效果的发动无效，且该卡在场上或墓地与该效果相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动无效的卡表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果2的发动条件：融合召唤的这张卡在怪兽区域由自己控制，且被对方破坏
function c6182103.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果2的回收目标过滤条件：可以加入手卡、属于「秘异三变」系列且处于表侧表示除外状态
function c6182103.thfilter(c,typ)
	return c:IsAbleToHand() and c:IsSetCard(0x157) and c:IsFaceup()
end
-- 效果2的选择组检查：选中的卡片组中，怪兽、魔法、陷阱卡各最多只能有1张
function c6182103.gcheck(g)
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and g:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
-- 效果2的目标处理：检查是否存在可回收的卡，并设置回收卡片加入手卡的操作信息
function c6182103.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查除外区是否存在至少1张可以加入手牌的「秘异三变」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6182103.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置将除外区的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果2的操作处理：从除外区选择怪兽、魔法、陷阱各最多1张的「秘异三变」卡加入手牌
function c6182103.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外区所有满足条件的「秘异三变」卡
	local g=Duel.GetMatchingGroup(c6182103.thfilter,tp,LOCATION_REMOVED,0,nil)
	if #g>0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,c6182103.gcheck,false,1,3)
		if sg then
			-- 将选中的卡片送回持有者的手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
