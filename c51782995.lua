--ネフティスの護り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选1张手卡破坏，从手卡把「奈芙提斯之护卫者」以外的1只4星以下的「奈芙提斯」怪兽特殊召唤。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从卡组选「奈芙提斯之护卫者」以外的1只「奈芙提斯」怪兽破坏。
function c51782995.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。选1张手卡破坏，从手卡把「奈芙提斯之护卫者」以外的1只4星以下的「奈芙提斯」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51782995,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,51782995)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c51782995.sptg)
	e1:SetOperation(c51782995.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c51782995.spr)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从卡组选「奈芙提斯之护卫者」以外的1只「奈芙提斯」怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51782995,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,51782996)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c51782995.descon)
	e3:SetTarget(c51782995.destg)
	e3:SetOperation(c51782995.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 筛选可特殊召唤的卡：属于「奈芙提斯」字段、等级4以下、可被特殊召唤且不是「奈芙提斯之护卫者」的怪兽。
function c51782995.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(51782995)
end
-- 手牌候选判断：用于选择要破坏的手牌时，确认除了当前候选卡之外，手牌中还存在其他可特殊召唤的「奈芙提斯」怪兽。
function c51782995.filter(c,e,tp)
	-- 在手牌中检索是否存在「奈芙提斯之护卫者」以外、4星以下且可特殊召唤的「奈芙提斯」怪兽，且该卡不是当前作为破坏候选的卡c。
	return Duel.IsExistingMatchingCard(c51782995.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- ①效果的发动条件判定：确认己方主要怪兽区有空位，且手牌中存在能够同时满足『破坏一张手牌』与『特殊召唤另一只奈芙提斯怪兽』的组合。
function c51782995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有空余位置，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的卡：至少有一张可被破坏的手牌，且破坏后还有另一张可被特殊召唤的「奈芙提斯」怪兽。
		and Duel.IsExistingMatchingCard(c51782995.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将破坏自己手牌的1张卡（具体卡在效果处理时选择），供连锁检测和效果发动时判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 登记操作信息：本次效果将从手牌特殊召唤1只「奈芙提斯」怪兽（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手牌选择1张卡破坏；破坏成功后，再从手牌选择1只符合条件的「奈芙提斯」怪兽表侧表示特殊召唤到自己场上。
function c51782995.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示『请选择要破坏的卡』的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从手牌中选择1张满足filter条件的卡作为破坏对象；filter保证了破坏该卡后手牌仍有可特召的怪兽。
	local g=Duel.SelectMatchingCard(tp,c51782995.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g==0 then return end
	-- 以效果破坏选择的卡；若实际破坏数量不为0（破坏成功），才继续执行后续特殊召唤。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 再次确认己方主要怪兽区仍有空位；若无空位则终止处理，避免特殊召唤失败。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向操作者显示『请选择要特殊召唤的卡』的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足spfilter条件的「奈芙提斯」怪兽作为特殊召唤对象。
		local g2=Duel.SelectMatchingCard(tp,c51782995.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 记录这张卡被效果破坏并送去墓地的时机，用于②效果在下次自己准备阶段的发动判定。
function c51782995.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断被效果破坏送去墓地时是否正值自己的准备阶段；若是，则需要额外标记，以排除在当前准备阶段立即发动②效果的情况。
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 将被破坏送去墓地时的回合数记录到效果标签中，用于与后续准备阶段的回合数比较。
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(51782995,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(51782995,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- ②效果的发动条件：当前为准备阶段且为持有者回合，这张卡之前被效果破坏送去墓地的标记存在，并且记录的被破坏回合不是当前回合（满足『下次』自己准备阶段）。
function c51782995.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 具体条件：记录的被破坏回合数≠当前回合数、当前是己方准备阶段、flag标记大于0（之前曾被效果破坏送去墓地）。
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(51782995)>0
end
-- 筛选卡组中可作为②效果破坏对象的卡：属于「奈芙提斯」字段、是怪兽卡、且不是「奈芙提斯之护卫者」。
function c51782995.desfilter(c)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_MONSTER) and not c:IsCode(51782995)
end
-- ②效果的目标判定：先确认卡组中存在符合条件的「奈芙提斯」怪兽；若存在，则取得全部候选组用于登记破坏信息，并清除之前的flag标记，表示本次发动已满足条件并消耗标记。
function c51782995.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件确认：己方卡组中是否存在至少1只符合条件的「奈芙提斯」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c51782995.desfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 检索己方卡组中所有符合条件的「奈芙提斯」怪兽，作为可能被破坏的候选范围。
	local g=Duel.GetMatchingGroup(c51782995.desfilter,tp,LOCATION_DECK,0,nil)
	-- 登记操作信息：在这些候选卡中会破坏1张（效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	c:ResetFlagEffect(51782995)
end
-- ②效果处理：从卡组选择1只符合条件的「奈芙提斯」怪兽以效果破坏。
function c51782995.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示『请选择要破坏的卡』的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从卡组选择1只满足desfilter条件的「奈芙提斯」怪兽。
	local g=Duel.SelectMatchingCard(tp,c51782995.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果破坏选择的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
