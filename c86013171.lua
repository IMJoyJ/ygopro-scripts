--Kozmo－パーヴィッド
-- 效果：
-- 「星际仙踪-小胆」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只3星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付500基本分，以除外的3只自己的「星际仙踪」怪兽为对象才能发动。那些怪兽回到墓地，给与对方500伤害。
function c86013171.initial_effect(c)
	-- 「星际仙踪-小胆」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只3星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86013171,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86013171)
	e1:SetCost(c86013171.spcost)
	e1:SetTarget(c86013171.sptg)
	e1:SetOperation(c86013171.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付500基本分，以除外的3只自己的「星际仙踪」怪兽为对象才能发动。那些怪兽回到墓地，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86013171,1))  --"除外的「星际仙踪」怪兽回到墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c86013171.cost)
	e2:SetTarget(c86013171.target)
	e2:SetOperation(c86013171.operation)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）函数：检查并执行将自身除外
function c86013171.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身表侧表示除外作为发动的代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：检索手卡中满足3星以上的「星际仙踪」怪兽且可以特殊召唤的卡
function c86013171.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）函数：检查怪兽区域空格以及手卡中是否存在可特殊召唤的怪兽，并设置操作信息
function c86013171.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上的怪兽区域是否有空位（因为自身作为代价除外会空出一个位置，所以可用空位数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且确认手卡中是否存在至少1只满足过滤条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c86013171.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理（Operation）函数：从手卡特殊召唤1只3星以上的「星际仙踪」怪兽
function c86013171.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c86013171.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检索除外区表侧表示的「星际仙踪」怪兽
function c86013171.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd2)
end
-- 效果②的发动代价（Cost）函数：检查并支付500基本分
function c86013171.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分作为发动的代价
	Duel.PayLPCost(tp,500)
end
-- 效果②的发动准备（Target）函数：选择除外的3只自己的「星际仙踪」怪兽为对象，并设置操作信息
function c86013171.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c86013171.filter(chkc) end
	-- 在发动检查时，确认自己除外区是否存在至少3只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c86013171.filter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择除外的3只自己的「星际仙踪」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86013171.filter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置连锁的操作信息：将选中的对象卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置连锁的操作信息：给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果②的效果处理（Operation）函数：使作为对象的怪兽回到墓地，并给与对方500点伤害
function c86013171.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 如果仍存在合法的对象卡，则将这些卡送回墓地，并确认是否成功送去墓地
	if sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)~=0 then
		-- 给与对方玩家500点效果伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
