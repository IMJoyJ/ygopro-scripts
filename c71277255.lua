--マナドゥム・リウムハート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只「末那愚子族」怪兽或者攻击力1500/守备力2100的怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「末那愚子族·里姆哈特」以外的1张「末那愚子族」卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（手牌二速破坏特召）和②效果（召唤·特召成功检索，包含通常召唤和特殊召唤两个触发时点）。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以自己场上1只「末那愚子族」怪兽或者攻击力1500/守备力2100的怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「末那愚子族·里姆哈特」以外的1张「末那愚子族」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 判定当前阶段是否为自己或对方的主要阶段1或主要阶段2。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤满足条件的怪兽：表侧表示、属于「末那愚子族」系列或攻击力1500且守备力2100，且该卡离开后能空出怪兽区域。
function s.tfilter(c,tp)
	local b1=c:IsSetCard(0x190)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	-- 过滤条件：卡片表侧表示，且该卡离开场上后自己场上有可用的怪兽区域，且满足系列名或攻防数值条件。
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0 and (b1 or b2)
end
-- ①效果的发动准备与对象选择，确认自身能否特殊召唤以及场上是否存在可选择的破坏对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少1只满足条件的可选择为对象的怪兽。
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1只满足条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：破坏选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：特殊召唤手牌中的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理：破坏作为对象的怪兽，若破坏成功，则将这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否仍适用效果，并将其因效果破坏，确认是否破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤检索卡片的条件：卡名不是「末那愚子族·里姆哈特」，属于「末那愚子族」系列，且能加入手牌。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x190) and c:IsAbleToHand()
end
-- ②效果的发动准备，确认卡组中是否存在可检索的卡片，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1张「末那愚子族」卡片加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
