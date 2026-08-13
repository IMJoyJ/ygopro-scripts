--機塊コンバート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的主要怪兽区域的「机块」连接怪兽全部除外。那之后，可以选最多有这个效果除外的怪兽数量的除外中的自己的「机块」连接怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，自己主要阶段从自己墓地把1张其他的「机块」魔法·陷阱卡除外才能发动。这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c27157996.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己的主要怪兽区域的「机块」连接怪兽全部除外。那之后，可以选最多有这个效果除外的怪兽数量的除外中的自己的「机块」连接怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27157996,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,27157996)
	e1:SetTarget(c27157996.target)
	e1:SetOperation(c27157996.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段从自己墓地把1张其他的「机块」魔法·陷阱卡除外才能发动。这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27157996,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27157997)
	-- 设置②效果的发动条件：此卡送去墓地的回合不能发动（利用aux.exccon判断当前回合是否为该卡送去墓地的回合）。
	e2:SetCondition(aux.exccon)
	e2:SetCost(c27157996.thcost)
	e2:SetTarget(c27157996.thtg)
	e2:SetOperation(c27157996.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果中要被除外的卡的条件：字段为「机块」的连接怪兽、位于自己主要怪兽区（序号0-4）且可以被除外。
function c27157996.filter(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and c:GetSequence()<5 and c:IsAbleToRemove()
end
-- ①效果的发动判定与操作信息设置：先确认存在满足条件的怪兽，再取出场上全部此类怪兽并设置除外它们的操作信息。
function c27157996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定自己场上是否存在至少1张满足filter条件的「机块」连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27157996.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 取得目前自己主要怪兽区域中所有满足filter条件的「机块」连接怪兽，作为本次除外的对象。
	local g=Duel.GetMatchingGroup(c27157996.filter,tp,LOCATION_MZONE,0,nil)
	-- 向系统登记本次连锁的除外信息：将刚刚取得的怪兽组g整体设为CATEGORY_REMOVE的对象，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 定义特殊召唤候选卡的条件：除外区表侧表示、字段为「机块」的连接怪兽，且能够以表侧表示被特殊召唤。
function c27157996.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：先除外所有符合条件的「机块」连接怪兽；若除外成功，则根据实际除外数、可用怪兽区和特殊召唤限制（如青眼精灵龙）确定可特召数量，再由玩家选择是否将其中若干只特殊召唤。
function c27157996.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新检索当前场上所有应被除外的「机块」连接怪兽，用于实际执行除外。
	local g=Duel.GetMatchingGroup(c27157996.filter,tp,LOCATION_MZONE,0,nil)
	-- 将取得的所有「机块」连接怪兽以表侧表示除外；若实际除外了至少1张，则继续后续处理。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 统计本次实际除外且仍在除外区的卡数量，作为后续可特殊召唤的数量上限。
		local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetCount()
		-- 从除外区筛选所有满足spfilter条件的「机块」连接怪兽，作为可供玩家特殊召唤的候选组。
		local sg=Duel.GetMatchingGroup(c27157996.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 获取自己场上可用的主要怪兽区空格数，用于限制特殊召唤的数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		ct=math.min(ct,ft)
		-- 在可特召数量大于0、存在候选怪兽，且玩家确认要特殊召唤时，才进入选择与召唤流程。
		if ct>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(27157996,2)) then  --"是否选怪兽特殊召唤？"
			-- 中断当前处理连锁，使随后的特殊召唤作为另一次处理进行，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家显示选择提示，要求从候选怪兽中选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,ct,nil)
			-- 将玩家选择的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果代价的筛选条件：墓地中「机块」字段的魔法·陷阱卡，且能够作为代价除外（调用时排除本卡）。
function c27157996.costfilter(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价处理：检查墓地是否存在其他可除外的「机块」魔法·陷阱卡，选择其中1张除外作为发动代价。
function c27157996.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动②效果的合法性判定：自己墓地存在至少1张符合条件的其他「机块」魔法·陷阱卡（排除本卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c27157996.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 显示选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足costfilter条件的「机块」魔法·陷阱卡（自动排除本卡），作为代价对象。
	local g=Duel.SelectMatchingCard(tp,c27157996.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 将选择作为代价的卡以表侧表示除外，支付②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：确认本卡可以被加入手牌，并设置回手牌的操作信息。
function c27157996.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 向系统登记本次连锁将本卡加入手牌（CATEGORY_TOHAND）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若本卡仍与效果关联（未被除外或移动），则将其加入持有者手牌。
function c27157996.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将本卡加入其持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
