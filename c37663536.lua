--古代の機械超巨人
-- 效果：
-- 「古代的机械」怪兽×3
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从额外卡组把1只「古代的机械究极巨人」无视召唤条件特殊召唤。
function c37663536.initial_effect(c)
	-- 注册此卡具有83104731这张卡的卡名
	aux.AddCodeList(c,83104731)
	c:EnableReviveLimit()
	-- 设置此卡的融合召唤条件为3个以上「古代的机械」怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),3,true)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37663536.condition)
	e1:SetOperation(c37663536.operation)
	c:RegisterEffect(e1)
	-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c37663536.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从额外卡组把1只「古代的机械究极巨人」无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c37663536.aclimit)
	e3:SetCondition(c37663536.actcon)
	c:RegisterEffect(e3)
	-- 记录融合召唤所用素材中「古代的机械」怪兽数量
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
-- 判断此卡是否为融合召唤 summoned
function c37663536.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsCode,nil,83104731,95735217))
end
-- 若融合召唤所用素材中「古代的机械」怪兽数量大于等于2，则增加攻击次数
function c37663536.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 「古代的机械超巨人」效果适用中
function c37663536.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>=2 then
		-- 禁止对方发动魔法·陷阱卡
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
-- 判断是否为攻击状态
function c37663536.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为攻击状态
function c37663536.actcon(e)
	-- 判断是否为攻击状态
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断是否为融合召唤且因对方效果离场
function c37663536.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选额外卡组中可特殊召唤的「古代的机械究极巨人」
function c37663536.spfilter(c,e,tp)
	-- 筛选额外卡组中可特殊召唤的「古代的机械究极巨人」
	return c:IsCode(12652643) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤操作信息
function c37663536.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可特殊召唤的「古代的机械究极巨人」
	if chk==0 then return Duel.IsExistingMatchingCard(c37663536.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作
function c37663536.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的卡
	local g=Duel.SelectMatchingCard(tp,c37663536.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
