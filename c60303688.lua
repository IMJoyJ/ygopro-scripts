--教導の聖女エクレシア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「教导的圣女 艾克莉西娅」以外的1张「教导」卡加入手卡。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ③：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
function c60303688.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60303688,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60303688)
	e1:SetCondition(c60303688.spcon)
	e1:SetTarget(c60303688.sptg)
	e1:SetOperation(c60303688.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「教导的圣女 艾克莉西娅」以外的1张「教导」卡加入手卡。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60303688,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,60303689)
	e2:SetTarget(c60303688.thtg)
	e2:SetOperation(c60303688.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c60303688.indes)
	c:RegisterEffect(e4)
end
-- 过滤条件：检查怪兽是否是从额外卡组特殊召唤的
function c60303688.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①号效果的特殊召唤发动条件：场上存在从额外卡组特殊召唤的怪兽
function c60303688.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只从额外卡组特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c60303688.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①号效果的特殊召唤发动准备：检查自身是否可以特殊召唤以及怪兽区域是否有空位
function c60303688.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的特殊召唤效果处理：将自身特殊召唤到场上
function c60303688.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中除「教导的圣女 艾克莉西娅」以外的「教导」卡片
function c60303688.thfilter(c)
	return c:IsSetCard(0x145) and not c:IsCode(60303688) and c:IsAbleToHand()
end
-- ②号效果的检索发动准备：检查卡组中是否存在可检索的卡，并设置操作信息
function c60303688.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查卡组中是否存在满足条件的「教导」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c60303688.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的检索效果处理：将卡片加入手卡，并适用直到回合结束时不能从额外卡组特殊召唤的限制
function c60303688.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「教导」卡片
	local g=Duel.SelectMatchingCard(tp,c60303688.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c60303688.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该回合内不能从额外卡组特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：限制特殊召唤的怪兽来源为额外卡组
function c60303688.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 战斗不破坏的判定条件：攻击此卡的怪兽是从额外卡组特殊召唤的
function c60303688.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
