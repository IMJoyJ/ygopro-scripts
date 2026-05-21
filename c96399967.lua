--機巧鳥－常世宇受賣長鳴
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只攻击力和守备力的数值相同的机械族怪兽解放才能发动。攻击力和守备力的数值相同而持有比解放的怪兽低的等级的1只机械族怪兽从卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从里侧表示除外的自己的卡之中选攻击力和守备力的数值相同的1只机械族怪兽加入手卡。
function c96399967.initial_effect(c)
	-- ①：把自己场上1只攻击力和守备力的数值相同的机械族怪兽解放才能发动。攻击力和守备力的数值相同而持有比解放的怪兽低的等级的1只机械族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96399967,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,96399967)
	e1:SetCost(c96399967.spcost)
	e1:SetTarget(c96399967.sptg)
	e1:SetOperation(c96399967.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从里侧表示除外的自己的卡之中选攻击力和守备力的数值相同的1只机械族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96399967,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,96399968)
	e2:SetTarget(c96399967.thtg)
	e2:SetOperation(c96399967.thop)
	c:RegisterEffect(e2)
end
-- 解放怪兽的过滤条件函数（攻守相同、机械族、等级大于1、解放后有可用怪兽区域、且卡组有可特召的对应怪兽）
function c96399967.costfilter(c,e,tp)
	-- 检查卡片是否为攻击力与守备力相同、且等级大于1的机械族怪兽
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:GetLevel()>1
		-- 检查该卡解放后是否能空出可用的怪兽区域，且该卡在自己场上或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足特殊召唤条件的、等级比该卡低的怪兽
		and Duel.IsExistingMatchingCard(c96399967.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
-- 从卡组特殊召唤的怪兽的过滤条件函数
function c96399967.spfilter(c,e,tp,lv)
	-- 检查卡片是否为攻击力与守备力相同的机械族怪兽
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
		and c:GetLevel()<lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动代价处理函数（解放场上1只攻守相同的机械族怪兽，并记录其等级）
function c96399967.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查场上是否存在至少1只满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c96399967.costfilter,1,nil,e,tp) end
	-- 让玩家选择1只满足解放条件的怪兽
	local sg=Duel.SelectReleaseGroup(tp,c96399967.costfilter,1,1,nil,e,tp)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 解放选中的怪兽作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 效果①的发动准备与目标确认函数
function c96399967.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（从卡组特殊召唤1只攻守相同且等级比解放怪兽低的机械族怪兽）
function c96399967.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只攻守相同且等级低于解放怪兽的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,c96399967.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 加入手牌的怪兽的过滤条件函数（里侧表示除外、攻守相同、机械族、能加入手牌）
function c96399967.thfilter(c)
	-- 检查卡片是否处于里侧表示除外状态，且攻击力与守备力相同
	return c:IsFacedown() and aux.AtkEqualsDef(c)
		and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标确认函数
function c96399967.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查除外区是否存在至少1张满足条件的里侧表示卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c96399967.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁信息，表示此效果包含从除外区将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果②的效果处理（从里侧除外卡中将1只攻守相同的机械族怪兽加入手牌并给对方确认）
function c96399967.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1张满足条件的里侧表示卡片
	local g=Duel.SelectMatchingCard(tp,c96399967.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
