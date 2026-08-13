--水晶機巧－クオンダム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以同调怪兽以外的自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
function c39964797.initial_effect(c)
	-- 为这张卡添加同调召唤手续：素材要求为任意调整＋调整以外的怪兽1只以上，使其可以作为同调怪兽进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39964797,0))  --"加速同调"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c39964797.sccon)
	e1:SetTarget(c39964797.sctg)
	e1:SetOperation(c39964797.scop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以同调怪兽以外的自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39964797,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c39964797.spcon)
	e2:SetTarget(c39964797.sptg)
	e2:SetOperation(c39964797.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断：仅当这张卡不处于连锁处理中，且当前回合玩家不是这张卡的控制者（即对方回合），并且当前阶段处于对方的主要阶段1/2或战斗阶段时，效果①才能发动。
function c39964797.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断这张卡不在连锁处理中，且当前回合玩家不是效果控制者tp（即这是对方的回合）。
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 效果①的发动目标：确认额外卡组中存在至少1只能够以这张卡为素材进行同调召唤的同调怪兽，并设定本次效果为从额外卡组特殊召唤1只同调怪兽。
function c39964797.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查额外卡组是否存在至少1张可以用这张卡作素材进行同调召唤的同调怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置操作信息：本次效果处理将进行特殊召唤，预计从额外卡组特殊召唤1只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的解决处理：确认这张卡仍在场上、控制者未变且表侧表示，然后从额外卡组选择1只符合条件的同调怪兽，以这张卡为素材进行实际同调召唤。
function c39964797.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有能够以这张卡为素材进行同调召唤的同调怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 向玩家显示选择要特殊召唤卡片的提示消息（“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为同调素材，将玩家选择的额外同调怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 效果②的发动条件：这张卡必须是同调召唤成功过的怪兽，破坏前位于怪兽区域，且是由于战斗或效果被破坏。
function c39964797.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 墓地特殊召唤的候选过滤条件：是自己墓地的「水晶机巧」怪兽、不是同调怪兽，并且能够被特殊召唤。
function c39964797.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标：需要自己存在可用怪兽区域，并且选择自己墓地1只满足条件的「水晶机巧」怪兽为对象；检查这些条件来决定是否可发动。
function c39964797.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39964797.spfilter(chkc,e,tp) end
	-- 发动时确认自己场上有可用的怪兽区域空格，以允许特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己墓地存在至少1只满足spfilter条件的「水晶机巧」怪兽可以作为效果对象；两部分条件都满足时效果②才可发动。
		and Duel.IsExistingTarget(c39964797.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤卡片的提示消息（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的「水晶机巧」怪兽，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c39964797.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理将把对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的解决处理：取得效果对象，若该卡仍与效果关联，则将其特殊召唤到自己的场上。
function c39964797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上，并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
