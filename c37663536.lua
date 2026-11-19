--古代の機械超巨人
-- 效果：
-- 「古代的机械」怪兽×3
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：融合召唤的表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从额外卡组把1只「古代的机械究极巨人」无视召唤条件特殊召唤。
function c37663536.initial_effect(c)
	-- 记录该卡效果文上记载了「古代的机械巨人」「古代的机械巨人-究极重击」「古代的机械究极巨人」的卡名
	aux.AddCodeList(c,83104731,95735217,12652643)
	c:EnableReviveLimit()
	-- 定义融合召唤素材条件：需要3只「古代的机械」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x7),3,true)
	-- ②：从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37663536.condition)
	e1:SetOperation(c37663536.operation)
	c:RegisterEffect(e1)
	-- 从「古代的机械巨人」「古代的机械巨人-究极重击」之中以合计2只以上为素材作融合召唤
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
-- 融合素材检查函数：统计这张卡的融合素材中「古代的机械巨人」和「古代的机械巨人-究极重击」的合计数量，并存入e1效果的Label中
function c37663536.valcheck(e,c)
	e:GetLabelObject():SetLabel(c:GetMaterial():FilterCount(Card.IsCode,nil,83104731,95735217))
end
-- ②效果的适用判断函数：确认这张卡是以融合召唤方式特殊召唤成功的
function c37663536.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②效果的赋予函数：若记录的指定素材数量达到2只以上，则为这张卡注册增加额外攻击次数（合计次数-1）的效果
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
-- 发动限制条件函数：禁止发动任何魔法·陷阱卡的卡片发动
function c37663536.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ①效果的生效条件函数：判断当前正在攻击的怪兽是否为这张卡自身
function c37663536.actcon(e)
	-- 检查当前攻击宣言及战斗阶段中的攻击怪兽是否就是这张卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- ③效果的发动条件函数：判断这张卡是否为融合召唤出场、离场前处于表侧表示，且因对方的效果从场上离开
function c37663536.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤条件函数：筛选额外卡组中可无视召唤条件特殊召唤且场地有空位的「古代的机械究极巨人」
function c37663536.spfilter(c,e,tp)
	-- 检查该卡是否为「古代的机械究极巨人」、能否被无视召唤条件特殊召唤，以及自己场上是否有供其从额外卡组出场的怪兽区空位
	return c:IsCode(12652643) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ③效果的目标与操作信息设置函数：确认额外卡组存在可特召的「古代的机械究极巨人」并登记特殊召唤操作信息
function c37663536.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己额外卡组存在至少1只符合条件的「古代的机械究极巨人」
	if chk==0 then return Duel.IsExistingMatchingCard(c37663536.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记操作信息：将会从自己额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果的处理函数：从自己额外卡组选择1只「古代的机械究极巨人」并无视召唤条件特殊召唤
function c37663536.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1只符合条件的「古代的机械究极巨人」
	local g=Duel.SelectMatchingCard(tp,c37663536.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「古代的机械究极巨人」无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
