--アマゾネス王女
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「亚马逊女王」使用。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「亚马逊」魔法·陷阱卡加入手卡。
-- ③：这张卡的攻击宣言时，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。从卡组把「亚马逊王女」以外的1只「亚马逊」怪兽守备表示特殊召唤。
function c84539520.initial_effect(c)
	-- 注册卡名变更效果，使这张卡在场上·墓地存在时卡名当作「亚马逊女王」使用
	aux.EnableChangeCode(c,15951532,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「亚马逊」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84539520,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,84539520)
	e2:SetTarget(c84539520.thtg)
	e2:SetOperation(c84539520.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击宣言时，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。从卡组把「亚马逊王女」以外的1只「亚马逊」怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84539520,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCost(c84539520.spcost)
	e4:SetTarget(c84539520.sptg)
	e4:SetOperation(c84539520.spop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中「亚马逊」魔法·陷阱卡且能加入手牌的卡片过滤函数
function c84539520.filter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②（检索「亚马逊」魔陷）的发动准备与可行性检查
function c84539520.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「亚马逊」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c84539520.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索「亚马逊」魔陷）的效果处理
function c84539520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「亚马逊」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c84539520.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤可以作为Cost送去墓地的卡片（若怪兽区已满，则必须选择场上的怪兽以腾出格子）
function c84539520.costfilter(c,ft)
	return c:IsAbleToGraveAsCost() and (ft>0 or (c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5))
end
-- 效果③（特召怪兽）的发动代价处理
function c84539520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家场上主要怪兽区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查手牌或场上是否存在除自身外至少1张可送去墓地的卡作为Cost
	if chk==0 then return Duel.IsExistingMatchingCard(c84539520.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,ft) end
	local g=nil
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	if ft<=0 then
		-- 当怪兽区没有空位时，强制从场上选择1张怪兽卡送去墓地
		g=Duel.SelectMatchingCard(tp,c84539520.costfilter,tp,LOCATION_MZONE,0,1,1,c,ft)
	else
		-- 当怪兽区有空位时，从手牌或场上选择1张卡送去墓地
		g=Duel.SelectMatchingCard(tp,c84539520.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,ft)
	end
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中「亚马逊王女」以外且可以特殊召唤的「亚马逊」怪兽
function c84539520.spfilter(c,e,tp)
	return c:IsSetCard(0x4) and not c:IsCode(84539520) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（特召怪兽）的发动准备与可行性检查
function c84539520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空间（考虑Cost可能腾出格子，所以此处判断大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查卡组中是否存在满足条件的「亚马逊」怪兽
		and Duel.IsExistingMatchingCard(c84539520.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③（特召怪兽）的效果处理
function c84539520.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「亚马逊」怪兽
	local g=Duel.SelectMatchingCard(tp,c84539520.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
