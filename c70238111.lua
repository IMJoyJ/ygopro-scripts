--リコーデッド・アライブ
-- 效果：
-- ①：以自己的场上·墓地1只连接3电子界族连接怪兽为对象才能发动。那只怪兽除外，从额外卡组把1只「码语者」怪兽特殊召唤。
-- ②：额外怪兽区域没有自己怪兽存在的场合，把墓地的这张卡除外，以除外的1只自己的「码语者」怪兽为对象才能发动。那只怪兽特殊召唤。
function c70238111.initial_effect(c)
	-- ①：以自己的场上·墓地1只连接3电子界族连接怪兽为对象才能发动。那只怪兽除外，从额外卡组把1只「码语者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c70238111.target)
	e1:SetOperation(c70238111.activate)
	c:RegisterEffect(e1)
	-- ②：额外怪兽区域没有自己怪兽存在的场合，把墓地的这张卡除外，以除外的1只自己的「码语者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c70238111.spcon)
	-- 设置发动cost为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c70238111.sptg)
	e2:SetOperation(c70238111.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己场上·墓地的连接3电子界族连接怪兽，且该卡可以除外，并且额外卡组存在可特殊召唤的「码语者」怪兽
function c70238111.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLink(3) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		-- 判定该卡是否可以除外，且额外卡组是否存在至少1只满足特殊召唤条件的「码语者」怪兽（将该卡作为离场预估对象）
		and c:IsAbleToRemove() and Duel.IsExistingMatchingCard(c70238111.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数：额外卡组的「码语者」怪兽，且可以特殊召唤，并且在预估rc离场后有可用的额外怪兽区域或主要怪兽区域空格
function c70238111.spfilter(c,e,tp,rc)
	-- 判定是否为「码语者」怪兽、是否可以特殊召唤，且在预估rc离场后是否有可用于从额外卡组特殊召唤该卡的空间
	return c:IsSetCard(0x101) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 效果①的靶向与发动准备函数（选择要除外的对象，并设置操作信息）
function c70238111.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) and c70238111.filter(chkc,e,tp) end
	-- 在发动准备阶段（chk==0），检查自己场上或墓地是否存在满足条件的连接3电子界族连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c70238111.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上或墓地1只满足条件的连接3电子界族连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70238111.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,e,tp)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若对象在墓地，设置效果处理信息为：将墓地的该卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	else
		-- 若对象在场上，设置效果处理信息为：将该卡除外
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
	-- 设置效果处理信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理函数（除外对象怪兽，并从额外卡组特殊召唤「码语者」怪兽）
function c70238111.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其表侧表示除外，且除外成功时才继续处理
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 给玩家发送提示信息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足特殊召唤条件的「码语者」怪兽
		local g=Duel.SelectMatchingCard(tp,c70238111.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if g:GetCount()>0 then
			-- 将选择的「码语者」怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：判定怪兽是否在额外怪兽区域（区域索引大于等于5）
function c70238111.cfilter(c)
	return c:GetSequence()>=5
end
-- 效果②的发动条件判定函数
function c70238111.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己场上的额外怪兽区域是否存在怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c70238111.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：除外区表侧表示的、可以特殊召唤的「码语者」怪兽
function c70238111.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x101) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向与发动准备函数（选择除外区要特殊召唤的对象）
function c70238111.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c70238111.spfilter2(chkc,e,tp) end
	-- 在发动准备阶段（chk==0），检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且除外区是否存在至少1只满足特殊召唤条件的自己的「码语者」怪兽
		and Duel.IsExistingTarget(c70238111.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的自己的「码语者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70238111.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为：将选择的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数（特殊召唤除外区的「码语者」怪兽）
function c70238111.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的对象怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
