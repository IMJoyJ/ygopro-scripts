--剛鬼ヘッドバット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡的场合，把这张卡以外的1只「刚鬼」怪兽从手卡送去墓地，以自己场上1只「刚鬼」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力直到回合结束时上升800。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 头锤蝙蝠」以外的1张「刚鬼」卡加入手卡。
function c54088068.initial_effect(c)
	-- ①：这张卡在手卡的场合，把这张卡以外的1只「刚鬼」怪兽从手卡送去墓地，以自己场上1只「刚鬼」怪兽为对象才能发动。这张卡从手卡守备表示特殊召唤，作为对象的怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54088068,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,54088068)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c54088068.spcost)
	e1:SetTarget(c54088068.sptg)
	e1:SetOperation(c54088068.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 头锤蝙蝠」以外的1张「刚鬼」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54088068,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,54088069)
	e2:SetCondition(c54088068.thcon)
	e2:SetTarget(c54088068.thtg)
	e2:SetOperation(c54088068.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除自身以外的「刚鬼」怪兽作为发动代价送去墓地
function c54088068.spcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfc) and c:IsAbleToGraveAsCost()
end
-- 效果①的代价值判定与支付：把这张卡以外的1只「刚鬼」怪兽从手卡送去墓地
function c54088068.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除自身以外的「刚鬼」怪兽可以作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c54088068.spcfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1只除自身以外的「刚鬼」怪兽
	local g=Duel.SelectMatchingCard(tp,c54088068.spcfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤自己场上表侧表示的「刚鬼」怪兽作为效果对象
function c54088068.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- 效果①的目标选择与发动准备（特殊召唤自身并选择场上1只「刚鬼」怪兽为对象）
function c54088068.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c54088068.spfilter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 并且检查自己场上是否存在可以作为对象的表侧表示「刚鬼」怪兽
		and Duel.IsExistingTarget(c54088068.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「刚鬼」怪兽作为效果对象
	Duel.SelectTarget(tp,c54088068.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表明该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的实际处理（特殊召唤自身并使对象怪兽攻击力上升800）
function c54088068.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否仍与效果相关，若成功将自身守备表示特殊召唤，且对象怪兽仍存在于场上表侧表示
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 作为对象的怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：检查这张卡是否是从场上送去墓地
function c54088068.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中「刚鬼 头锤蝙蝠」以外的1张「刚鬼」卡
function c54088068.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(54088068) and c:IsAbleToHand()
end
-- 效果②的目标选择与发动准备（检索卡组中的「刚鬼」卡）
function c54088068.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「刚鬼 头锤蝙蝠」以外的「刚鬼」卡可以加入手卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54088068.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明该效果包含从卡组将卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的实际处理（从卡组将「刚鬼」卡加入手卡）
function c54088068.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中「刚鬼 头锤蝙蝠」以外的1张「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c54088068.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
