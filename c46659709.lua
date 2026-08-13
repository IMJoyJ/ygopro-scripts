--銀河戦士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把1只其他的光属性怪兽送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡特殊召唤时才能发动。从卡组把1只「银河」怪兽加入手卡。
function c46659709.initial_effect(c)
	-- ①：从手卡把1只其他的光属性怪兽送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46659709,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c46659709.spcost)
	e1:SetTarget(c46659709.sptg)
	e1:SetOperation(c46659709.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤时才能发动。从卡组把1只「银河」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46659709,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,46659709)
	e2:SetTarget(c46659709.target)
	e2:SetOperation(c46659709.operation)
	c:RegisterEffect(e2)
end
-- 定义代价筛选函数：检查卡片是否为光属性，且可以作为代价（COST）从手卡送去墓地。
function c46659709.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 效果1的代价处理：确认时检查手卡是否存在1只除本卡以外的光属性怪兽且可作为代价；实际发动时从手卡选择并丢弃1只满足条件的怪兽作为COST。
function c46659709.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查手卡中是否存在至少1只满足条件的光属性怪兽（排除此卡自身）作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c46659709.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡选择1只符合条件的光属性怪兽（除本卡以外）作为代价丢弃到墓地。
	Duel.DiscardHand(tp,c46659709.cfilter,1,1,REASON_COST,e:GetHandler())
end
-- 效果1的发动条件检查：确认自己主要怪兽区有空位，且此卡可以表侧守备表示特殊召唤到自己场上。
function c46659709.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置本次连锁的操作信息，声明将特殊召唤此卡1张，使系统识别该效果属于特殊召唤类别。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1处理时：若此卡仍与效果保持关联，则将其表侧守备表示特殊召唤到自己场上。
function c46659709.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧守备表示将此卡特殊召唤到自己场上（不检查召唤条件、不检查苏生限制，作为效果处理）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义检索筛选函数：选择卡组中持有‘银河’字段、是怪兽卡且能够加入手卡的卡片。
function c46659709.filter(c)
	return c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果2的发动条件检查：确认卡组中存在符合条件的‘银河’怪兽；并设置操作信息为从卡组检索加入手卡。
function c46659709.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查卡组中是否存在至少1只符合条件的‘银河’怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c46659709.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：表示该效果将把1张卡从卡组加入手卡（具体卡在效果处理时选择，因此目标暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果2处理时：提示玩家选择要加入手牌的卡，从卡组选1只符合条件的‘银河’怪兽加入手牌，并让对方确认。
function c46659709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示：‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合筛选条件的‘银河’怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c46659709.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手玩家确认加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
