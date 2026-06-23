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
	-- 设置效果目标为场上所有「无形噬体」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe0))
	e2:SetValue(c50554729.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：自己的手卡·场上的怪兽被解放的场合或者被战斗·效果破坏的场合才能发动。从卡组把1张「无形噬体」卡加入手卡。
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
-- 过滤函数，用于判断是否为正面表示的「无形噬体」怪兽
function c50554729.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 计算场上「无形噬体」怪兽数量并乘以100作为攻击力/守备力增加量
function c50554729.value(e,c)
	-- 获取场上正面表示的「无形噬体」怪兽数量
	return Duel.GetMatchingGroupCount(c50554729.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*100
end
-- 过滤函数，用于判断被解放的卡是否为自己的手牌或场上的怪兽
function c50554729.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 条件函数，检查是否有自己的手牌或场上的怪兽被解放
function c50554729.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50554729.cfilter1,1,nil,tp)
end
-- 过滤函数，用于判断被破坏的卡是否为自己的手牌或场上的怪兽且因战斗或效果破坏
function c50554729.cfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsPreviousControler(tp)
end
-- 条件函数，检查是否有自己的手牌或场上的怪兽被战斗或效果破坏
function c50554729.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50554729.cfilter2,1,nil,tp)
end
-- 过滤函数，用于检索卡组中可加入手牌的「无形噬体」卡
function c50554729.thfilter(c)
	return c:IsSetCard(0xe0) and c:IsAbleToHand()
end
-- 设置连锁操作信息，准备从卡组检索一张「无形噬体」卡加入手牌
function c50554729.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中存在至少一张「无形噬体」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50554729.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定要处理的卡为卡组中的一张「无形噬体」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作，选择并加入手牌
function c50554729.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「无形噬体」卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c50554729.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
