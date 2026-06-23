--百鬼羅刹 特攻ダグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。场上1个超量素材取除，这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「哥布林骑手」魔法·陷阱卡加入手卡。
function c24079759.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。场上1个超量素材取除，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24079759,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,24079759)
	e1:SetTarget(c24079759.sptg)
	e1:SetOperation(c24079759.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「哥布林骑手」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24079759,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,24079759+1)
	e2:SetTarget(c24079759.thtg)
	e2:SetOperation(c24079759.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查是否满足特殊召唤的条件：移除1张超量素材、场上存在空位、此卡可特殊召唤。
function c24079759.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件：移除1张超量素材、场上存在空位。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作：移除超量素材并特殊召唤此卡。
function c24079759.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 移除超量素材成功且此卡仍在场上时，执行特殊召唤。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义检索卡牌的过滤条件：哥布林骑手系列的魔法或陷阱卡且可加入手牌。
function c24079759.thfilter(c)
	return c:IsSetCard(0x10ac) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索卡牌的处理信息：从卡组检索1张符合条件的卡加入手牌。
function c24079759.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24079759.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索卡牌的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索卡牌操作：选择并加入手牌，然后确认对方看到该卡。
function c24079759.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌。
	local g=Duel.SelectMatchingCard(tp,c24079759.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
