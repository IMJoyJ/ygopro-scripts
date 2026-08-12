--機塊コンバート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的主要怪兽区域的「机块」连接怪兽全部除外。那之后，可以选最多有这个效果除外的怪兽数量的除外中的自己的「机块」连接怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，自己主要阶段从自己墓地把1张其他的「机块」魔法·陷阱卡除外才能发动。这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c27157996.initial_effect(c)
	-- ①：自己的主要怪兽区域的「机块」连接怪兽全部除外。那之后，可以选最多有这个效果除外的怪兽数量的除外中的自己的「机块」连接怪兽特殊召唤。
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
	-- 设置效果条件为：这张卡送去墓地的回合不能发动此效果
	e2:SetCondition(aux.exccon)
	e2:SetCost(c27157996.thcost)
	e2:SetTarget(c27157996.thtg)
	e2:SetOperation(c27157996.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选自己主要怪兽区中满足条件的「机块」连接怪兽（包括除外条件）
function c27157996.filter(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and c:GetSequence()<5 and c:IsAbleToRemove()
end
-- 效果处理时的判断函数，检查是否有满足条件的怪兽存在，并设置操作信息为除外这些怪兽
function c27157996.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：自己主要怪兽区存在至少1张「机块」连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27157996.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取满足条件的「机块」连接怪兽组
	local g=Duel.GetMatchingGroup(c27157996.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息为除外这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 过滤函数，用于筛选除外区中满足条件的「机块」连接怪兽（用于特殊召唤）
function c27157996.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，将场上符合条件的怪兽除外，并根据除外数量决定是否特殊召唤
function c27157996.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「机块」连接怪兽组
	local g=Duel.GetMatchingGroup(c27157996.filter,tp,LOCATION_MZONE,0,nil)
	-- 将场上符合条件的怪兽除外，如果成功则继续处理
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 获取实际被除外的怪兽数量
		local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetCount()
		-- 获取除外区中满足条件的「机块」连接怪兽组
		local sg=Duel.GetMatchingGroup(c27157996.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 获取自己主要怪兽区的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		ct=math.min(ct,ft)
		-- 判断是否满足特殊召唤条件：有可除外的怪兽数量、有可特殊召唤的怪兽、玩家选择特殊召唤
		if ct>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(27157996,2)) then  --"是否选怪兽特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,ct,nil)
			-- 将玩家选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，用于筛选墓地中满足条件的「机块」魔法·陷阱卡（用于除外作为cost）
function c27157996.costfilter(c)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果处理函数，从墓地中除外一张「机块」魔法·陷阱卡作为cost
function c27157996.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足条件：自己墓地存在至少1张「机块」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27157996.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张「机块」魔法·陷阱卡除外
	local g=Duel.SelectMatchingCard(tp,c27157996.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 将选中的卡除外作为cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数，设置将此卡加入手牌的操作信息
function c27157996.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡加入手牌
function c27157996.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
