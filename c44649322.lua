--伝承の大御巫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只「御巫」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在对方结束阶段回到手卡。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把「传承的大御巫」以外的1张「御巫」卡送去墓地。
function c44649322.initial_effect(c)
	-- ①：从手卡把1只「御巫」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在对方结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44649322,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,44649322)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c44649322.target)
	e1:SetOperation(c44649322.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把「传承的大御巫」以外的1张「御巫」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44649322,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44649323)
	-- 设置②效果的发动代价：将墓地里的这张卡除外（由aux.bfgcost实现cost的检查与执行）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44649322.tgtg)
	e2:SetOperation(c44649322.tgop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的怪兽条件：手卡中的怪兽且属于「御巫」字段，并满足可被无视召唤条件地特殊召唤（不检查召唤条件，但遵守苏生限制）。
function c44649322.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动条件判定与操作信息设置：检查自己场上是否有可用怪兽区、手卡中是否有符合条件的「御巫」怪兽可特殊召唤，并设置特殊召唤的操作信息。
function c44649322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否仍有可用的主要怪兽区域空位，以确定能否进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的「御巫」怪兽，作为特殊召唤的候选。
		and Duel.IsExistingMatchingCard(c44649322.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本效果将要进行‘从手卡特殊召唤1只怪兽’的操作信息（目标位置为手卡，数量1），用于连锁检测与效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：在仍有可用怪兽区的情况下，从手卡选择1只符合条件的「御巫」怪兽，无视召唤条件以表侧表示特殊召唤，并给其设置‘对方结束阶段返回手卡’的标记和诱发效果；完成后结束特殊召唤流程。
function c44649322.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若发现自己场上没有可用怪兽区空位，则特殊召唤不进行，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡（提示消息为‘请选择要特殊召唤的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡筛选出1张符合条件的「御巫」怪兽，由玩家选择作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c44649322.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中的卡存在且能通过特殊召唤步骤被特殊召唤，则将其以表侧表示特殊召唤到自己场上；本次特殊召唤无视召唤条件（nocheck=true），但遵守苏生限制（nolimit=false）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(44649322,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- ①：从手卡把1只「御巫」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在对方结束阶段回到手卡。②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把「传承的大御巫」以外的1张「御巫」卡送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c44649322.thcon)
		e1:SetOperation(c44649322.thop)
		-- 将刚创建的‘对方结束阶段回到手卡’的持续效果注册到当前玩家场上的效果处理中，使该效果在满足条件时生效。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤步骤的收尾，宣告由Duel.SpecialSummonStep开始的特殊召唤全部处理完毕，怪兽正式特殊召唤成功。
	Duel.SpecialSummonComplete()
end
-- 定义回到手卡效果发动/适用的条件：必须是对方结束阶段，且该怪兽仍持有本次特殊召唤时赋予的标记（fid）；若标记已消失，则重置该效果并视为条件不满足。
function c44649322.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为对方回合（1-tp），若不是则回手效果不发动。
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(44649322)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 定义回手效果的处理：将被标记的怪兽返回持有者手卡。
function c44649322.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 把目标怪兽加入其持有者的手卡，作为该效果的处理结果。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 定义②效果从卡组选送墓地的卡的条件：属于「御巫」字段、卡名不是「传承的大御巫」本身、且能够被送去墓地。
function c44649322.tgfilter(c)
	return c:IsSetCard(0x18d) and not c:IsCode(44649322) and c:IsAbleToGrave()
end
-- ②效果的发动条件判定与操作信息设置：检查卡组中是否存在符合条件的「御巫」卡，并登记‘送去墓地’的操作信息。
function c44649322.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在至少1张符合tgfilter的卡（即非「传承的大御巫」的「御巫」卡），确保可以送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(c44649322.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本效果将要‘从卡组把1张卡送去墓地’的操作信息，位置为卡组，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「御巫」卡，将其送去墓地。
function c44649322.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要送去墓地的卡（提示消息为‘请选择要送去墓地的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组筛选出1张满足tgfilter的「御巫」卡，由玩家选择作为送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c44649322.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
