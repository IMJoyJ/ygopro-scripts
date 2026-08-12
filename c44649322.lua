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
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44649322.tgtg)
	e2:SetOperation(c44649322.tgop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中满足条件的「御巫」怪兽
function c44649322.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足①效果的发动条件
function c44649322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的「御巫」怪兽
		and Duel.IsExistingMatchingCard(c44649322.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理①效果的发动
function c44649322.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中满足条件的「御巫」怪兽
	local g=Duel.SelectMatchingCard(tp,c44649322.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(44649322,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册一个在对方结束阶段触发的效果，用于将特殊召唤的怪兽送回手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c44649322.thcon)
		e1:SetOperation(c44649322.thop)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否为对方的结束阶段且特殊召唤的怪兽满足条件
function c44649322.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方的结束阶段
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(44649322)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将特殊召唤的怪兽送回手卡
function c44649322.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽送回手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 过滤卡组中满足条件的「御巫」卡
function c44649322.tgfilter(c)
	return c:IsSetCard(0x18d) and not c:IsCode(44649322) and c:IsAbleToGrave()
end
-- 判断是否满足②效果的发动条件
function c44649322.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「御巫」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44649322.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果的发动
function c44649322.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择卡组中满足条件的「御巫」卡
	local g=Duel.SelectMatchingCard(tp,c44649322.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
