--ゴーティスの死棘グオグリム
-- 效果：
-- 鱼族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽除外。
-- ②：对方准备阶段才能发动。这张卡除外。那之后，若作为这张卡的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化怪兽效果：解除苏生限制，注册同调召唤手续（鱼族调整+调整以外怪兽1只以上），并注册①除外对方怪兽和②除外自身后特殊召唤同调素材的两个效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤条件：鱼族调整1只+调整以外怪兽1只以上（此处调整以外为1只以上）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FISH),aux.NonTuner(nil),1)
	-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：对方准备阶段才能发动。这张卡除外。那之后，若作为这张卡的同调召唤的素材用过的一组怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与取对象：获取与这张卡战斗的对方怪兽，确认其存在、为对方控制且可除外，然后设置操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemove() end
	-- 设置操作信息：本次效果将除外对象怪兽（1只）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- ①效果处理：若战斗对象仍与战斗相关，则将其表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 将对象怪兽以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前为对方回合的准备阶段（对方准备阶段）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果发动时的目标判定：确认自身可以除外，并设置除外自身的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 设置操作信息：本次效果将除外自身（1张）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 同调素材怪兽的筛选条件：属于自己且在墓地、作为此卡同调召唤的素材使用过、且可以特殊召唤（不受苏生限制）。
function s.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：先除外自身；若自身在除外区且为同调召唤、素材齐集且满足特殊召唤条件并经玩家确认，则将那一组素材特殊召唤，并给这些怪兽附加离场时除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetMaterial()
	local ct=#mg
	-- 检查自身是否成功除外、现在位于除外区且是通过同调召唤出场的怪兽。
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED) and c:GetSummonType()==SUMMON_TYPE_SYNCHRO
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133)) and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查所有同调素材都满足可特殊召唤的条件且数量一致，并询问玩家是否要特殊召唤那一组素材。
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)==ct and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把同调素材怪兽特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤处理与之前的除外处理视为不同时处理（避免错失时点）。
		Duel.BreakEffect()
		-- 遍历同调素材组中的每张怪兽卡。
		for tc in aux.Next(mg) do
			-- 将当前素材作为特殊召唤过程的一步进行特殊召唤（若成功则继续附加效果）。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				tc:RegisterEffect(e1,true)
			end
		end
		-- 完成整个特殊召唤流程（与SpecialSummonStep配合使用，触发特殊召唤成功时的时点）。
		Duel.SpecialSummonComplete()
	end
end
