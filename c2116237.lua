--世壊輪廻
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只表侧表示的「维萨斯-斯塔弗罗斯特」直到结束阶段除外才能发动。把1只攻击力3000的「哈特」怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽只能有1次把效果发动，结束阶段里侧除外。
-- ②：这张卡在墓地存在的状态，对方从额外卡组把怪兽特殊召唤的场合才能发动。这张卡加入手卡。
function c2116237.initial_effect(c)
	-- 给此卡注册代码列表，标明效果文中记载了「维萨斯-斯塔弗罗斯特」（56099748）这一卡名，用于规则上识别相关卡名。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把自己场上1只表侧表示的「维萨斯-斯塔弗罗斯特」直到结束阶段除外才能发动。把1只攻击力3000的「哈特」怪兽无视召唤条件从额外卡组特殊召唤。这个效果特殊召唤的怪兽只能有1次把效果发动，结束阶段里侧除外。
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
-- 代价筛选：从场上选择表侧表示且可作为代价除外的「维萨斯-斯塔弗罗斯特」，同时确认额外卡组中存在可特殊召唤的符合条件的「哈特」怪兽。
function c2116237.costfilter(c,e,tp)
	return c:IsCode(56099748) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
		-- 额外卡组中必须至少有1只满足特殊召唤条件的「哈特」怪兽，否则不能选择该维萨斯作为代价。
		and Duel.IsExistingMatchingCard(c2116237.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤筛选：选择额外卡组中「哈特」字段且攻击力3000、可被无视召唤条件特殊召唤的怪兽，并确认有足够的额外怪兽区域空位。
function c2116237.spfilter(c,e,tp,sc)
	return c:IsSetCard(0x1a0) and c:IsAttack(3000) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 确认除外作为代价的「维萨斯」后，己方额外怪兽区域存在空位可供「哈特」怪兽特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- ①代价处理：从场上选择并暂时除外1只表侧表示的「维萨斯-斯塔弗罗斯特」，若除外成功且不是衍生物，则注册一个在结束阶段将该怪兽返回场上的效果。
function c2116237.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：若场上存在可作为代价的「维萨斯」且额外有可特殊召唤的怪兽，则代价条件成立，可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2116237.costfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 弹出提示信息，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己场上选择1张符合条件的「维萨斯-斯塔弗罗斯特」作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c2116237.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选择的卡以『代价』和『暂时除外』的理由除外；若成功除外则继续后续处理。
	if Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local rc=g:GetFirst()
		if rc:IsType(TYPE_TOKEN) then return end
		-- 把自己场上1只表侧表示的「维萨斯-斯塔弗罗斯特」直到结束阶段除外才能发动。把1只攻击力3000的「哈特」怪兽无视召唤条件从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(2116237,2))  --"发动时除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c2116237.retop)
		-- 将结束阶段归还除外的维萨斯的效果注册到场上，使其在结束阶段自动处理。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段处理函数：把此前因代价暂时除外的「维萨斯-斯塔弗罗斯特」返回场上。
function c2116237.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行返回场上操作，将暂时除外的怪兽按原形式送回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- ①效果的目标处理：效果发动时检查能否特殊召唤，并设置本次连锁的特殊召唤操作信息。
function c2116237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前检查：若代价已经确认，或额外卡组存在可特殊召唤的「哈特」怪兽，则允许进行后续处理。
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(c2116237.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil) end
	-- 设置操作信息，声明本次效果将从额外卡组特殊召唤1只怪兽，供系统与其他效果交互。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的发动处理：选择1只符合条件的「哈特」怪兽无视召唤条件特殊召唤，并为其附加『只能发动1次效果』和『结束阶段里侧除外』的制约。
function c2116237.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出提示信息，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只攻击力3000的「哈特」怪兽作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c2116237.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 如果成功选择了怪兽且将其以表侧表示特殊召唤（无视召唤条件、不检查苏生限制），则继续给该怪兽附加限制效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(2116237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 结束阶段里侧除外。
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
		-- 注册结束阶段里侧除外的不入连锁处理效果。
		Duel.RegisterEffect(e1,tp)
		-- 这个效果特殊召唤的怪兽只能有1次把效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetRange(LOCATION_MZONE)
		e2:SetOperation(c2116237.aclimit)
		tc:RegisterEffect(e2)
		-- 这个效果特殊召唤的怪兽只能有1次把效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_TRIGGER)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetCondition(c2116237.econ)
		e3:SetValue(c2116237.elimit)
		tc:RegisterEffect(e3)
	end
	-- 完成整个特殊召唤流程，正式确定特殊召唤成功。
	Duel.SpecialSummonComplete()
end
-- 结束阶段除外效果的发动条件：该怪兽仍是本效果特殊召唤的那只怪兽（通过标志位认证）。
function c2116237.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(2116237)==e:GetLabel()
end
-- 结束阶段除外效果的处理：将对应的「哈特」怪兽里侧除外。
function c2116237.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽以里侧表示除外，除外的原因记为效果。
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
end
-- 监视该怪兽的效果发动：当它发动效果时，给它打上标记，表示已经发动过一次效果。
function c2116237.aclimit(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()~=e:GetHandler() then return end
	e:GetHandler():RegisterFlagEffect(2116238,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 禁止该怪兽发动效果的条件：存在已发动过效果的标记时，禁止其发动。
function c2116237.econ(e)
	return e:GetHandler():GetFlagEffect(2116238)~=0
end
-- 限制效果只对该怪兽自身生效，即只禁止它自己的效果发动，不影响其他卡。
function c2116237.elimit(e,te,tp)
	return te:GetHandler()==e:GetHandler()
end
-- 筛选出对方从额外卡组特殊召唤的怪兽（召唤来源为额外卡组，召唤玩家为对方）。
function c2116237.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- ②效果发动条件：对方从额外卡组把怪兽特殊召唤成功时，满足条件可以发动。
function c2116237.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2116237.cfilter,1,nil,tp)
end
-- ②效果的目标处理：确认这张卡可以加入手卡，并设置回手牌的操作信息。
function c2116237.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，声明本次效果将把此卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍在墓地且与发动效果关联，则将其加入持有者手卡。
function c2116237.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 把墓地中的此卡送回持有者手卡，原因是效果。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
