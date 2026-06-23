--風帝家臣ガルーム
-- 效果：
-- 「风帝家臣 迦楼姆」的①②的效果1回合各能使用1次。
-- ①：让自己场上1只上级召唤的怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。从卡组把「风帝家臣 迦楼姆」以外的1只攻击力800/守备力1000的怪兽加入手卡。
function c22382087.initial_effect(c)
	-- ①：让自己场上1只上级召唤的怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22382087)
	e1:SetCost(c22382087.spcost)
	e1:SetTarget(c22382087.sptg)
	e1:SetOperation(c22382087.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为上级召唤而被解放的场合才能发动。从卡组把「风帝家臣 迦楼姆」以外的1只攻击力800/守备力1000的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,22382088)
	e2:SetCondition(c22382087.thcon)
	e2:SetTarget(c22382087.thtg)
	e2:SetOperation(c22382087.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查自己场上是否存在1只上级召唤的怪兽且能送入手牌作为费用
function c22382087.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- 效果处理时，检查自己场上是否存在1只上级召唤的怪兽且能送入手牌作为费用，若存在则选择1只送入手牌作为费用
function c22382087.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1只上级召唤的怪兽且能送入手牌作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(c22382087.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只满足条件的上级召唤怪兽送入手牌作为费用
	local g=Duel.SelectMatchingCard(tp,c22382087.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将所选怪兽送入手牌作为费用
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 判断是否满足特殊召唤的条件，包括自己场上是否有足够的怪兽区域以及此卡是否能被特殊召唤
function c22382087.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示此效果将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，创建一个使自己不能从额外卡组特殊召唤怪兽的效果并注册，然后将此卡特殊召唤
function c22382087.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建一个使自己不能从额外卡组特殊召唤怪兽的效果并注册，然后将此卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22382087.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制效果，使不能特殊召唤额外卡组的怪兽
function c22382087.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 判断此卡是否因上级召唤而被解放
function c22382087.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- 过滤函数，检查卡组中是否存在攻击力800/守备力1000且不是此卡的怪兽
function c22382087.filter(c)
	return c:IsAttack(800) and c:IsDefense(1000) and not c:IsCode(22382087) and c:IsAbleToHand()
end
-- 判断是否满足检索条件，即卡组中是否存在满足条件的怪兽
function c22382087.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在攻击力800/守备力1000且不是此卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22382087.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果将从卡组检索1张符合条件的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，提示玩家选择1张符合条件的怪兽加入手牌，并确认对方看到该卡
function c22382087.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c22382087.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到所选怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
