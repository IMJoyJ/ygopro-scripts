--PSYフレーム・アクセラレーター
-- 效果：
-- ①：1回合1次，支付500基本分，以自己场上1只「PSY骨架」怪兽为对象才能发动。那只怪兽直到下次的自己准备阶段除外。
-- ②：1回合1次，这张卡以外的自己场上的表侧表示的「PSY骨架」卡因战斗以外从场上离开的场合才能发动。从手卡把1只「PSY骨架」怪兽特殊召唤。
function c51053997.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付500基本分，以自己场上1只「PSY骨架」怪兽为对象才能发动。那只怪兽直到下次的自己准备阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51053997,2))  --"选择1只怪兽除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(c51053997.cost)
	e3:SetTarget(c51053997.target)
	e3:SetOperation(c51053997.operation)
	c:RegisterEffect(e3)
	-- ②：1回合1次，这张卡以外的自己场上的表侧表示的「PSY骨架」卡因战斗以外从场上离开的场合才能发动。从手卡把1只「PSY骨架」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51053997,3))  --"手卡怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c51053997.spcon)
	e4:SetTarget(c51053997.sptg)
	e4:SetOperation(c51053997.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：卡名属于「PSY骨架」且能够被除外。
function c51053997.rmfilter(c)
	return c:IsSetCard(0xc1) and c:IsAbleToRemove()
end
-- 发动代价函数：检查并支付500基本分作为发动代价。
function c51053997.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 效果发动时的取对象处理：从自己场上选择1只「PSY骨架」怪兽作为对象，并设置除外操作信息。
function c51053997.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51053997.rmfilter(chkc) end
	-- 检查自己场上是否存在至少1只「PSY骨架」怪兽可以成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c51053997.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只自己场上的「PSY骨架」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c51053997.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息：本次效果将除外1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将对象怪兽暂时除外，并设置其在下次自己准备阶段返回场上的效果；若在准备阶段发动，则调整为下一个自己准备阶段返回。
function c51053997.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其暂时除外（因效果，标记为暂时离场）。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local ct=1
		-- 若发动时正处于自己的准备阶段，则将返回标记持续时间设为2，使返回发生在下一个自己准备阶段。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then ct=2 end
		-- ①：1回合1次，支付500基本分，以自己场上1只「PSY骨架」怪兽为对象才能发动。那只怪兽直到下次的自己准备阶段除外。②：1回合1次，这张卡以外的自己场上的表侧表示的「PSY骨架」卡因战斗以外从场上离开的场合才能发动。从手卡把1只「PSY骨架」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(51053997,4))  --"除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c51053997.retcon)
		e1:SetOperation(c51053997.retop)
		-- 判断当前是否为发动者自己的准备阶段，若是则需要额外等待一次准备阶段再返回。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 记录当前回合数，用于排除发动当次的准备阶段，确保返回发生在下一个自己准备阶段。
			e1:SetValue(Duel.GetTurnCount())
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
		end
		-- 将返回处理效果注册到场上，持续监测准备阶段时点。
		Duel.RegisterEffect(e1,tp)
		tc:RegisterFlagEffect(51053998,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,ct)
	end
end
-- 返回处理的条件判定：仅当到达自己的准备阶段且不是发动时的准备阶段，且对象怪兽仍带有返回标记时允许返回。
function c51053997.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前不是自己的准备阶段，或仍是发动当次的准备阶段，则不满足返回条件。
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(51053998)~=0
end
-- 返回处理操作：将被暂时除外的对象怪兽返回场上。
function c51053997.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将暂时除外的怪兽以离场前的表示形式返回场上。
	Duel.ReturnToField(tc)
end
-- 筛选离场事件中的卡：卡名属于「PSY骨架」、离场前在场上表侧表示且控制者为发动者。
function c51053997.cfilter(c,tp)
	return c:IsPreviousSetCard(0xc1) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- ②效果的触发条件：离场组中存在符合条件的「PSY骨架」卡（且不包含这张卡自身），同时这张卡效果处于有效状态。
function c51053997.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51053997.cfilter,1,e:GetHandler(),tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 手卡特召的过滤条件：卡名属于「PSY骨架」且可以被当前效果特殊召唤。
function c51053997.spfilter(c,e,tp)
	return c:IsSetCard(0xc1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：这张卡仍与效果相关、自己怪兽区有空位、手卡中有可特召的「PSY骨架」怪兽；满足则设置特召操作信息。
function c51053997.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 需要自己主要怪兽区存在可用空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 需要手卡中存在至少1只符合条件的「PSY骨架」怪兽。
		and Duel.IsExistingMatchingCard(c51053997.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从手卡特召1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的处理：从手卡选择1只「PSY骨架」怪兽，以表侧表示特殊召唤到自己场上。
function c51053997.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己主要怪兽区仍有空格，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出要选择特殊召唤怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只符合条件的「PSY骨架」怪兽。
	local g=Duel.SelectMatchingCard(tp,c51053997.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
