--ネフティスの護り手
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选1张手卡破坏，从手卡把「奈芙提斯之护卫者」以外的1只4星以下的「奈芙提斯」怪兽特殊召唤。
-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从卡组选「奈芙提斯之护卫者」以外的1只「奈芙提斯」怪兽破坏。
function c51782995.initial_effect(c)
	-- ①：自己主要阶段才能发动。选1张手卡破坏，从手卡把「奈芙提斯之护卫者」以外的1只4星以下的「奈芙提斯」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51782995,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,51782995)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c51782995.sptg)
	e1:SetOperation(c51782995.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏送去墓地的场合，下次的自己准备阶段才能发动。从卡组选「奈芙提斯之护卫者」以外的1只「奈芙提斯」怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c51782995.spr)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
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
-- 过滤手卡中满足条件的「奈芙提斯」怪兽（4星以下、非本卡、可特殊召唤）
function c51782995.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(51782995)
end
-- 检查手卡是否存在满足特殊召唤条件的「奈芙提斯」怪兽
function c51782995.filter(c,e,tp)
	-- 检查手卡是否存在满足特殊召唤条件的「奈芙提斯」怪兽
	return Duel.IsExistingMatchingCard(c51782995.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 判断效果发动条件：是否有足够的怪兽区域和符合条件的手卡怪兽
function c51782995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断效果发动条件：是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断效果发动条件：是否存在符合条件的手卡怪兽
		and Duel.IsExistingMatchingCard(c51782995.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将要破坏的手卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将要特殊召唤的手卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果发动：选择并破坏手卡，然后特殊召唤符合条件的怪兽
function c51782995.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的手卡作为破坏对象
	local g=Duel.SelectMatchingCard(tp,c51782995.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g==0 then return end
	-- 执行破坏操作并判断是否成功
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 判断是否有足够的怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的手卡作为特殊召唤对象
		local g2=Duel.SelectMatchingCard(tp,c51782995.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 将符合条件的怪兽特殊召唤到场上
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 处理卡片被破坏送入墓地时的效果触发
function c51782995.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if bit.band(r,0x41)~=0x41 then return end
	-- 判断是否为当前回合玩家且处于准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数以供后续判断
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(51782995,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(51782995,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断效果发动条件：是否为下次准备阶段且满足触发条件
function c51782995.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断效果发动条件：是否为下次准备阶段且满足触发条件
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(51782995)>0
end
-- 过滤卡组中符合条件的「奈芙提斯」怪兽（非本卡、为怪兽）
function c51782995.desfilter(c)
	return c:IsSetCard(0x11f) and c:IsType(TYPE_MONSTER) and not c:IsCode(51782995)
end
-- 设置操作信息：将要破坏的卡组怪兽数量为1
function c51782995.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断效果发动条件：卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51782995.desfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取满足条件的卡组怪兽集合
	local g=Duel.GetMatchingGroup(c51782995.desfilter,tp,LOCATION_DECK,0,nil)
	-- 设置操作信息：将要破坏的卡组怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	c:ResetFlagEffect(51782995)
end
-- 处理效果发动：选择并破坏卡组中的怪兽
function c51782995.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡组怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的卡组怪兽作为破坏对象
	local g=Duel.SelectMatchingCard(tp,c51782995.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽从卡组破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
