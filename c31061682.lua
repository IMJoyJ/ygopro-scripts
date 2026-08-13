--Kozmo－ドロッセル
-- 效果：
-- 「星际仙踪-多萝塞尔」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡给与对方战斗伤害时，支付500基本分才能发动。从卡组把1张「星际仙踪」卡加入手卡。
function c31061682.initial_effect(c)
	-- 「星际仙踪-多萝塞尔」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只4星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31061682,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31061682)
	e1:SetCost(c31061682.spcost)
	e1:SetTarget(c31061682.sptg)
	e1:SetOperation(c31061682.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，支付500基本分才能发动。从卡组把1张「星际仙踪」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c31061682.thcon)
	e2:SetCost(c31061682.thcost)
	e2:SetTarget(c31061682.thtg)
	e2:SetOperation(c31061682.thop)
	c:RegisterEffect(e2)
end
-- 发动①效果的代价：将自己（场上的这张卡）表侧表示除外，作为发动效果所需支付的cost，不进入连锁。
function c31061682.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自己除外的具体操作：以表侧表示形式将这张卡除外，除外原因标记为cost，表示这是发动代价支付。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 特殊召唤的素材筛选条件：从手卡中选出具有「星际仙踪」字段、等级为4星以上，且可以被当前效果正常特殊召唤的怪兽。
function c31061682.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动前的合法性检查：确认除外自己后怪兽区域仍有可用空格，且手卡中存在至少1只满足特殊召唤条件的「星际仙踪」怪兽。
function c31061682.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区的可用空格数是否大于-1。由于发动代价要除外自己，因此即使当前格子数为0，除外后也能腾出1个格子，所以用>-1作为判定条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认手卡中存在至少1张满足spfilter筛选条件的「星际仙踪」怪兽，这是能够发动①效果的前提。
		and Duel.IsExistingMatchingCard(c31061682.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向决斗系统登记操作信息：本效果将从手卡特殊召唤1只怪兽（不取对象，数量为1，来源位置为手卡），供相关卡牌效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的实际处理：若除外自己后仍无可用怪兽区则直接终止；否则让玩家从手卡选择1只符合条件的「星际仙踪」怪兽，以表侧表示特殊召唤到自己场上。
function c31061682.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己怪兽区域是否还有空位，若没有可用区域则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示框，提示当前玩家需要选择1只要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中筛选并选择1张满足spfilter条件的「星际仙踪」怪兽，作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c31061682.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧表示特殊召唤到自己场上；这里不指定召唤方式（sumtype=0），且不无视召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的触发条件：战斗伤害的承受者不是这张卡的控制者，即这张卡给与对方玩家造成了战斗伤害。
function c31061682.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ②效果的发动代价：先检查自己能否支付500基本分，可以则实际支付500基本分。
function c31061682.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否能够支付500点基本分作为发动代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500点基本分，作为②效果的cost。
	Duel.PayLPCost(tp,500)
end
-- 检索卡组的筛选条件：卡片具有「星际仙踪」字段，并且可以被加入手卡。
function c31061682.thfilter(c)
	return c:IsSetCard(0xd2) and c:IsAbleToHand()
end
-- ②效果的目标判断：确认卡组中存在至少1张符合条件的「星际仙踪」卡，并登记操作信息：从卡组将1张卡加入手卡。
function c31061682.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在至少1张满足thfilter筛选条件的「星际仙踪」卡，这是②效果能够发动的条件之一。
	if chk==0 then return Duel.IsExistingMatchingCard(c31061682.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向决斗系统登记操作信息：本效果将从卡组把1张卡加入手卡（不取对象，数量为1，来源为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：让玩家从卡组选择1张「星际仙踪」卡加入手卡，并向对方玩家展示那张卡。
function c31061682.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示框，提示当前玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张满足thfilter条件的「星际仙踪」卡，作为加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c31061682.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入其持有者的手卡（即加入手牌），原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认己方加入手卡的那张卡，保证信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
