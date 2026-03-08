--水晶機巧－クオンダム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为同调素材作同调召唤。
-- ②：同调召唤的这张卡被战斗·效果破坏的场合，以同调怪兽以外的自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
function c39964797.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求必须有1只调整和1只调整以外的怪兽作为同调素材
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
-- 判断是否满足同调召唤的发动条件，包括当前阶段是否为对方的主要阶段或战斗阶段，且不在连锁中
function c39964797.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否不在连锁中且当前回合玩家不是自己
	return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 设置同调召唤效果的目标，检查是否存在满足条件的同调怪兽
function c39964797.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足同调召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置操作信息，表示将要特殊召唤同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行同调召唤的操作，选择并进行同调召唤
function c39964797.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取满足同调召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 判断是否满足墓地特殊召唤的发动条件，即该卡是从场上被破坏且为同调召唤
function c39964797.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤满足条件的墓地「水晶机巧」怪兽，排除同调怪兽
function c39964797.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置墓地特殊召唤效果的目标，检查是否存在满足条件的墓地怪兽
function c39964797.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39964797.spfilter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c39964797.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地怪兽
	local g=Duel.SelectTarget(tp,c39964797.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行墓地特殊召唤的操作，将目标怪兽特殊召唤
function c39964797.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
