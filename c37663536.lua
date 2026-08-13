--古代の機械超巨人
-- 效果：
-- 「古代的机械」怪兽×3
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从额外卡组把1只「古代的机械究极巨人」无视召唤条件特殊召唤。
function c37663536.initial_effect(c)
	-- 将卡号83104731（古代的机械巨人）加入该卡的代码列表，用于记录此卡文本中记载了该卡名，供相关效果（如素材判别）使用。
	aux.AddCodeList(c,83104731)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：要求以3只属于「古代的机械」系列的怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),3,true)
	-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37663536.condition)
	e1:SetOperation(c37663536.operation)
	c:RegisterEffect(e1)
	-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c37663536.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c37663536.aclimit)
	e3:SetCondition(c37663536.actcon)
	c:RegisterEffect(e3)
	-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从额外卡组把1只「古代的机械究极巨人」无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37663536,0))  --"特殊召唤「古代的机械究极巨人」"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c37663536.spcon)
	e4:SetTarget(c37663536.sptg)
	e4:SetOperation(c37663536.spop)
	c:RegisterEffect(e4)
end
-- 素材检查回调：统计这张卡融合召唤使用的素材中卡号为83104731（古代的机械巨人）或95735217（古代的机械巨人-究极重击）的数量，并把数量存入e1的标签（Label）中，供后续赋予攻击次数使用。
function c37663536.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsCode,nil,83104731,95735217))
end
-- 连续效果e1的触发条件：这张卡特殊召唤成功，且召唤方式为融合召唤。
function c37663536.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时的处理：若素材检查中符合条件的素材数量ct≥2，则给自己设置一个额外攻击效果：使这张卡在同一战斗阶段中增加ct-1次攻击（合计最多攻击ct次），并设定离场等标准时机重置。
function c37663536.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>=2 then
		-- 在同1次的战斗阶段中可以作出最多有那个数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(37663536,1))  --"「古代的机械超巨人」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 限制效果判定：只有当对方发动的效果类型为‘魔法·陷阱卡的发动’（EFFECT_TYPE_ACTIVATE）时，才会被禁止。
function c37663536.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制效果适用条件：当前正在进行攻击的怪兽是这张卡自身（即这张卡攻击的场合）。
function c37663536.actcon(e)
	-- 判断当前攻击怪兽是否为这张卡自身，用于决定是否适用‘对方不能发动魔法·陷阱卡’的限制。
	return Duel.GetAttacker()==e:GetHandler()
end
-- ③的发动条件：这张卡必须是融合召唤、此前表侧表示存在于场上、因对方的效果（reason player为1-tp）离场，且离场原因为效果。
function c37663536.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤对象过滤：选择卡号为12652643（古代的机械究极巨人）、可无视召唤条件特殊召唤、且额外卡组怪兽有足够空位可以出场的卡。
function c37663536.spfilter(c,e,tp)
	-- 同时确认该卡是「古代的机械究极巨人」、能被无视召唤条件特殊召唤、以及自己场上存在可供额外卡组怪兽特殊召唤的空格。
	return c:IsCode(12652643) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ③的发动时点处理：在发动时检查额外卡组是否存在符合条件的「古代的机械究极巨人」；若存在，则登记特殊召唤操作信息。
function c37663536.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件：检查额外卡组中是否存在至少1只满足特殊召唤条件的「古代的机械究极巨人」，以此决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37663536.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次连锁将进行‘从额外卡组把1只怪兽特殊召唤’的操作信息，使其他卡片（如星尘龙等）能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③的处理：从额外卡组选择1只「古代的机械究极巨人」，将其无视召唤条件，以表侧表示特殊召唤到自己的场上。
function c37663536.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示‘请选择要特殊召唤的卡’的选择提示，用于选择待特殊召唤的额外卡组怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的额外卡组中选择1只满足spfilter条件的卡（即「古代的机械究极巨人」且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c37663536.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「古代的机械究极巨人」无视召唤条件，以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
