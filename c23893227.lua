--サイバー・ドラゴン・コア
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡召唤的场合发动。从卡组把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
-- ③：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。从卡组把1只「电子龙」怪兽特殊召唤。
function c23893227.initial_effect(c)
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。②：这张卡召唤的场合发动。从卡组把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23893227,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,23893227)
	e1:SetTarget(c23893227.target)
	e1:SetOperation(c23893227.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。③：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。从卡组把1只「电子龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23893227,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23893227)
	e2:SetCondition(c23893227.spcon)
	-- 设置③效果发动时需将墓地中的此卡除外作为代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23893227.sptg)
	e2:SetOperation(c23893227.spop)
	c:RegisterEffect(e2)
	-- 为这张卡注册在场上·墓地时卡名当作「电子龙」（70095154）使用的效果。
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 过滤函数：筛选卡组中持有「电子」（0x93）或「电子科技」（0x94）字段的魔法·陷阱卡，且能够加入手卡的卡。
function c23893227.filter(c)
	return c:IsSetCard(0x93,0x94) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动条件判定与发动时的操作信息设置：满足发动条件（无其他检查），并声明将进行从卡组检索加入手卡的处理。
function c23893227.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次效果将要从卡组把1张卡加入手卡，用于卡组检索相关判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从持有者卡组挑选1张符合条件的「电子」/「电子科技」魔法·陷阱卡加入手牌，并向对方确认。
function c23893227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示当前玩家从卡组选择1张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足 c23893227.filter 条件的卡供玩家选择。
	local g=Duel.SelectMatchingCard(tp,c23893227.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件判定：对方场上存在怪兽，且自己场上没有怪兽。
function c23893227.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 只有对方场上存在怪兽（tp 的对方区域 LOCATION_MZONE 数量>0），且己方场上没有怪兽（tp 的己方区域数量==0）时条件成立。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数：筛选卡组中卡名持有「电子龙」（0x1093）字段的怪兽，且能被玩家 tp 用效果特殊召唤。
function c23893227.spfilter(c,e,tp)
	return c:IsSetCard(0x1093) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标（处理前）判定：检查己方怪兽区有空位，且卡组中存在满足特殊召唤条件的「电子龙」怪兽。
function c23893227.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查己方场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查卡组中是否有符合条件的「电子龙」怪兽存在。
		and Duel.IsExistingMatchingCard(c23893227.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将要从卡组特殊召唤1只怪兽，用于特殊召唤相关判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只「电子龙」怪兽以表侧表示特殊召唤；若没有空位则处理终止。
function c23893227.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认怪兽区有空位，若没有空位则特殊召唤处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示当前玩家从卡组选择1只要特殊召唤的「电子龙」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选出1只满足 c23893227.spfilter 条件的「电子龙」怪兽，不选取对象。
	local g=Duel.SelectMatchingCard(tp,c23893227.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
