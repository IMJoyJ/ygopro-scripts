--悪魔嬢アリス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1张陷阱卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤成功时，以自己墓地1只「恶魔娘」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡被解放的场合或者被对方破坏的场合才能发动。从卡组把「恶魔娘 爱莉丝」以外的1只攻击力·守备力的合计是2000的恶魔族怪兽加入手卡。
function c14504454.initial_effect(c)
	-- ①：从自己的手卡·墓地把1张陷阱卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14504454)
	e1:SetCost(c14504454.sscost)
	e1:SetTarget(c14504454.sstg)
	e1:SetOperation(c14504454.ssop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时，以自己墓地1只「恶魔娘」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c14504454.sptg)
	e2:SetOperation(c14504454.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合或者被对方破坏的场合才能发动。从卡组把「恶魔娘 爱莉丝」以外的1只攻击力·守备力的合计是2000的恶魔族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,14504455)
	e3:SetTarget(c14504454.thtg)
	e3:SetOperation(c14504454.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c14504454.thcon)
	c:RegisterEffect(e4)
end
-- 过滤函数，检查是否满足除外陷阱卡的条件
function c14504454.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，用于处理①效果的费用支付
function c14504454.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌和墓地是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c14504454.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c14504454.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的陷阱卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数，用于处理①效果的发动条件
function c14504454.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，用于处理①效果的发动效果
function c14504454.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，检查是否满足特殊召唤墓地「恶魔娘」怪兽的条件
function c14504454.spfilter(c,e,tp)
	return c:IsSetCard(0x174) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，用于处理②效果的发动条件
function c14504454.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14504454.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的「恶魔娘」怪兽
		and Duel.IsExistingTarget(c14504454.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c14504454.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，用于处理②效果的发动效果
function c14504454.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，检查是否满足检索条件的恶魔族怪兽
function c14504454.thfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(14504454) and c:IsAbleToHand()
		and c:IsAttackAbove(0) and c:IsDefenseAbove(0) and c:GetAttack()+c:GetDefense()==2000
end
-- 效果处理函数，用于处理③效果的发动条件
function c14504454.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组是否存在满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14504454.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要将怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于处理③效果的发动效果
function c14504454.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的恶魔族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c14504454.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的恶魔族怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断③效果是否因被解放或被破坏而发动的条件
function c14504454.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
