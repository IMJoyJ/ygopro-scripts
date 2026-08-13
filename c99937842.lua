--TG スター・ガーディアン
-- 效果：
-- 调整＋调整以外的「科技属」怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己主要阶段才能发动。从手卡把1只「科技属」怪兽特殊召唤。
-- ③：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
function c99937842.initial_effect(c)
	-- 为这张卡添加同调召唤手续（对应召唤条件‘调整＋调整以外的「科技属」怪兽1只以上’）：调整不做限定，调整以外的素材必须是「科技属」怪兽（SetCard 0x27），数量为1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x27),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡特殊召唤的场合，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99937842,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,99937842)
	e1:SetTarget(c99937842.thtg)
	e1:SetOperation(c99937842.thop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡把1只「科技属」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99937842,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,99937843)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c99937842.sptg)
	e2:SetOperation(c99937842.spop)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段才能发动（同一连锁上最多1次）。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99937842,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c99937842.sccon)
	e3:SetTarget(c99937842.sctg)
	e3:SetOperation(c99937842.scop)
	c:RegisterEffect(e3)
end
-- 定义过滤条件：选择的对象必须是「科技属」怪兽（SetCard 0x27）、怪兽卡，并且能够被效果加入手牌。
function c99937842.thfilter(c,tp)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时处理：若在效果处理前指定对象（chkc），检查该对象是否在己方墓地且满足thfilter；否则检查己方墓地是否存在至少1张满足条件的「科技属」怪兽，并从中选择1张作为对象，同时设置“回手牌”的操作信息。
function c99937842.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99937842.thfilter(chkc) end
	-- 发动时确认：己方墓地存在至少1张满足回手条件的「科技属」怪兽（可选对象）。
	if chk==0 then return Duel.IsExistingTarget(c99937842.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向己方玩家显示“请选择要加入手牌的卡”的选择提示（仅界面提示，不影响规则）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方墓地选择1只满足条件的「科技属」怪兽，并将其设置为当前连锁的处理对象。
	local sg=Duel.SelectTarget(tp,c99937842.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：效果包含“回手牌”分类，对象为已选择的卡片，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ①效果处理时：取得发动时选择的对象卡，若该卡仍与效果相关（未被无效/转移），则将其加入持有者手牌。
function c99937842.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡（即发动①时选择的墓地「科技属」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以“效果”为原因加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义特殊召唤过滤条件：目标必须是「科技属」怪兽，且可以对当前效果进行特殊召唤（处理是否合法）。
function c99937842.spfilter(c,e,tp)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时处理：检查己方主要怪兽区是否有空位，以及手牌中是否有至少1只可特殊召唤的「科技属」怪兽；满足后设置“特殊召唤”的操作信息。
function c99937842.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认：己方场上有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时确认：手牌中存在至少1只满足特殊召唤条件的「科技属」怪兽。
		and Duel.IsExistingMatchingCard(c99937842.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：效果包含“特殊召唤”分类，对象不确定（处理时选择），数量为1，来源为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理时：若己方主要怪兽区已无空位则中止；否则选择手牌中1只满足条件的「科技属」怪兽，以表侧攻击表示特殊召唤到己方场上。
function c99937842.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认：己方主要怪兽区有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向己方玩家显示“请选择要特殊召唤的卡”的选择提示（仅界面提示，不影响规则）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足特殊召唤条件的「科技属」怪兽。
	local g=Duel.SelectMatchingCard(tp,c99937842.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上（以通常的效果特殊召唤方式，不视为同调召唤）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：当前回合玩家不是这张卡的控制者（即对方回合），且当前阶段为主要阶段1或主要阶段2。
function c99937842.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是己方（是对方），即满足“对方主要阶段”的回合条件。
	return Duel.GetTurnPlayer()~=tp
		-- 当前阶段为主要阶段1或主要阶段2（满足“主要阶段”的阶段条件）。
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ③效果的发动时处理：检查额外卡组是否存在至少1只可以以这张卡为素材进行同调召唤的同调怪兽；满足后设置“特殊召唤”的操作信息。
function c99937842.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认：额外卡组中存在至少1只可在这张卡作为素材的前提下进行同调召唤的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置当前连锁的操作信息：效果包含“特殊召唤”分类，对象不确定（处理时选择），数量为1，来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理时：若这张卡不再在己方场上、控制权已改变或为里侧表示，则效果不处理；否则从额外卡组选择1只可用这张卡作为素材的同调怪兽，以这张卡为调整素材进行同调召唤。
function c99937842.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 取得额外卡组中所有可以以这张卡为素材进行同调召唤的同调怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 向己方玩家显示“请选择要特殊召唤的卡”的选择提示（仅界面提示，不影响规则）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为调整素材，将选择的同调怪兽进行同调召唤（从额外卡组特殊召唤到场上）。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
