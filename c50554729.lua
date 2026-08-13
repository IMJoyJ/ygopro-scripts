--アモルファージ・インフェクション
-- 效果：
-- 「无形噬体感染」的②的效果1回合只能使用1次。
-- ①：场上的「无形噬体」怪兽的攻击力·守备力上升场上的「无形噬体」卡数量×100。
-- ②：自己的手卡·场上的怪兽被解放的场合或者被战斗·效果破坏的场合才能发动。从卡组把1张「无形噬体」卡加入手卡。
function c50554729.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「无形噬体」怪兽的攻击力·守备力上升场上的「无形噬体」卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 将攻击力提升效果的对象限定为场上所有「无形噬体」怪兽；该增减效果本身只对表侧表示怪兽生效。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe0))
	e2:SetValue(c50554729.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 「无形噬体感染」的②的效果1回合只能使用1次。②：自己的手卡·场上的怪兽被解放的场合才能发动。从卡组把1张「无形噬体」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_RELEASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,50554729)
	e4:SetCondition(c50554729.thcon1)
	e4:SetTarget(c50554729.thtg)
	e4:SetOperation(c50554729.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c50554729.thcon2)
	c:RegisterEffect(e5)
end
-- 定义场上表侧表示且属于「无形噬体」字段的卡为有效数量统计对象，用于计算攻防提升数值。
function c50554729.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 计算场上符合条件的「无形噬体」卡数量并乘以100，作为攻击力·守备力的提升值。
function c50554729.value(e,c)
	-- 统计场上表侧表示的「无形噬体」卡数量后乘以100，返回攻防提升的具体数值。
	return Duel.GetMatchingGroupCount(c50554729.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
end
-- 定义“自己的手卡·场上的怪兽被解放”的判定条件：被解放的怪兽需为怪兽，且解放前位于我方手牌或场上，控制者为我方。
function c50554729.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 当本次解放的怪兽中存在至少1只符合“自己的手卡·场上的怪兽被解放”条件的怪兽时，允许②效果发动。
function c50554729.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50554729.cfilter1,1,nil,tp)
end
-- 定义“自己的手卡·场上的怪兽被战斗或效果破坏”的判定条件：被破坏的怪兽为怪兽，破坏原因为战斗或效果，且破坏前位于我方手牌或场上，控制者为我方。
function c50554729.cfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 当本次被破坏的怪兽中存在至少1只符合“自己的手卡·场上的怪兽被战斗或效果破坏”条件的怪兽时，允许②效果发动。
function c50554729.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50554729.cfilter2,1,nil,tp)
end
-- 定义检索条件：卡组中属于「无形噬体」字段且能够加入手卡的卡片。
function c50554729.thfilter(c)
	return c:IsSetCard(0xe0) and c:IsAbleToHand()
end
-- ②效果的发动时处理：确认卡组中存在符合条件的「无形噬体」卡，并将本次操作登记为从卡组将1张卡加入手牌。
function c50554729.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中至少有1张符合条件的「无形噬体」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c50554729.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次操作信息登记为“从卡组把1张卡加入手牌”，供后续效果处理及相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组将1张符合条件的「无形噬体」卡加入手卡，并让对方确认这张卡。
function c50554729.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，供玩家从卡组中选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从发动者卡组中筛选并选择1张符合条件的「无形噬体」卡。
	local g=Duel.SelectMatchingCard(tp,c50554729.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「无形噬体」卡加入其持有者的手牌，原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
