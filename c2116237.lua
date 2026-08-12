--世壊輪廻
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只表侧表示的「维萨斯-斯塔弗罗斯特」直到结束阶段除外才能发动。把1只攻击力3000的「哈特」怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽只能有1次把效果发动，结束阶段里侧除外。
-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合才能发动。这张卡加入手卡。
function c2116237.initial_effect(c)
	-- 记录此卡具有「维萨斯-斯塔弗罗斯特」的卡名
	aux.AddCodeList(c,56099748)
	-- ①：把自己场上1只表侧表示的「维萨斯-斯塔弗罗斯特」直到结束阶段除外才能发动。把1只攻击力3000的「哈特」怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽只能有1次把效果发动，结束阶段里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2116237,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,2116237)
	e1:SetCost(c2116237.cost)
	e1:SetTarget(c2116237.target)
	e1:SetOperation(c2116237.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2116237,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,2116238)
	e2:SetCondition(c2116237.thcon)
	e2:SetTarget(c2116237.thtg)
	e2:SetOperation(c2116237.thop)
	c:RegisterEffect(e2)
end
-- 用于筛选满足条件的「维萨斯-斯塔弗罗斯特」怪兽作为cost
function c2116237.costfilter(c,e,tp)
	return c:IsCode(56099748) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
		-- 检查是否存在满足特殊召唤条件的「哈特」怪兽
		and Duel.IsExistingMatchingCard(c2116237.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 用于筛选满足条件的「哈特」怪兽
function c2116237.spfilter(c,e,tp,sc)
	return c:IsSetCard(0x1a0) and c:IsAttack(3000) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查场上是否有足够的位置进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 设置发动效果的cost，需要除外1只「维萨斯-斯塔弗罗斯特」
function c2116237.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足cost条件
	if chk==0 then return Duel.IsExistingMatchingCard(c2116237.costfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的「维萨斯-斯塔弗罗斯特」怪兽除外
	local g=Duel.SelectMatchingCard(tp,c2116237.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选中的怪兽以临时除外形式移除
	if Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local rc=g:GetFirst()
		if rc:IsType(TYPE_TOKEN) then return end
		-- 发动时除外的怪兽回到场上
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(2116237,2))  --"发动时除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c2116237.retop)
		-- 注册效果，使除外的怪兽在结束阶段回到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 将除外的怪兽返回场上
function c2116237.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将除外的怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 设置效果的目标，准备特殊召唤怪兽
function c2116237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(c2116237.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil) end
	-- 设置操作信息，表示要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果，从额外卡组特殊召唤1只攻击力3000的「哈特」怪兽
function c2116237.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的「哈特」怪兽进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,c2116237.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(2116237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 特殊召唤的怪兽里侧除外
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(2116237,3))  --"特殊召唤的怪兽里侧除外"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c2116237.rmcon)
		e1:SetOperation(c2116237.rmop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使特殊召唤的怪兽在结束阶段里侧除外
		Duel.RegisterEffect(e1,tp)
		-- 防止特殊召唤的怪兽发动效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetRange(LOCATION_MZONE)
		e2:SetOperation(c2116237.aclimit)
		tc:RegisterEffect(e2)
		-- 禁止特殊召唤的怪兽发动效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetCondition(c2116237.econ)
		e3:SetValue(c2116237.elimit)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否满足特殊召唤怪兽的除外条件
function c2116237.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(2116237)==e:GetLabel()
end
-- 执行特殊召唤怪兽的除外操作
function c2116237.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将特殊召唤的怪兽以里侧形式除外
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
end
-- 记录特殊召唤怪兽的发动限制
function c2116237.aclimit(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()~=e:GetHandler() then return end
	e:GetHandler():RegisterFlagEffect(2116238,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断是否满足发动限制条件
function c2116237.econ(e)
	return e:GetHandler():GetFlagEffect(2116238)~=0
end
-- 限制特殊召唤怪兽发动效果
function c2116237.elimit(e,te,tp)
	return te:GetHandler()==e:GetHandler()
end
-- 用于筛选对方从额外卡组特殊召唤的怪兽
function c2116237.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 判断是否满足墓地效果发动条件
function c2116237.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2116237.cfilter,1,nil,tp)
end
-- 设置墓地效果的目标
function c2116237.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，表示要将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 发动墓地效果，将卡加入手卡
function c2116237.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
