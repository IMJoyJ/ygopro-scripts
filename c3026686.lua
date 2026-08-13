--ワルキューレ・ドリット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「女武神三女」以外的1张「女武神」卡加入手卡。
-- ②：这张卡的攻击力上升除外的对方怪兽数量×200。
function c3026686.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「女武神三女」以外的1张「女武神」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3026686,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3026686)
	e1:SetTarget(c3026686.thtg)
	e1:SetOperation(c3026686.thop)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力上升除外的对方怪兽数量×200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c3026686.atkvalue)
	c:RegisterEffect(e4)
end
-- 定义检索过滤器：要求卡属于「女武神」字段（0x122）、能够加入手卡、且不是「女武神三女」（卡号3026686）自身。
function c3026686.thfilter(c)
	return c:IsSetCard(0x122) and c:IsAbleToHand() and not c:IsCode(3026686)
end
-- ①效果的发动条件判定与操作信息设置：若卡组存在至少1张符合条件的「女武神」卡则允许发动，并设定将卡组中的1张卡加入手牌的操作信息。
function c3026686.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查卡组中是否存在至少1张满足thfilter条件的卡，作为效果能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c3026686.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果预定从卡组把1张卡加入控制者手牌（不取对象的检索），供发动时点检测等后续判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理流程：从卡组中选择1张符合条件的「女武神」卡加入手牌，并将其展示给对方玩家。
function c3026686.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前玩家显示选择提示信息，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由玩家从自己卡组中筛选并选择1张满足thfilter条件的卡（这是效果处理时进行的选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c3026686.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手牌，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手（1-tp）确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果统计攻击力所使用的除外怪兽过滤器：要求是表侧表示的怪兽卡（调用时会限定在对方的除外区）。
function c3026686.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- ②效果的攻击力上升值计算函数：统计对方除外区中满足rmfilter条件的怪兽数量，并乘以200作为上升值。
function c3026686.atkvalue(e,c)
	-- 返回符合条件的怪兽数量×200，作为这张卡的攻击力上升数值。
	return Duel.GetMatchingGroupCount(c3026686.rmfilter,c:GetControler(),0,LOCATION_REMOVED,nil)*200
end
