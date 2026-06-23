--No.53 偽骸神 Heart－eartH
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，这张卡被选择作为攻击对象的场合发动。这张卡的攻击力直到回合结束时上升那只攻击怪兽的原本攻击力数值。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：没有超量素材的这张卡被效果破坏送去墓地的场合发动。这张卡作为超量素材，从额外卡组把1只「No.92 伪骸神龙 心地心龙」当作超量召唤作特殊召唤。
function c23998625.initial_effect(c)
	-- 为卡片添加等级为5、需要3只怪兽作为素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，这张卡被选择作为攻击对象的场合发动。这张卡的攻击力直到回合结束时上升那只攻击怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23998625,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c23998625.atktg)
	e1:SetOperation(c23998625.atkop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c23998625.reptg)
	c:RegisterEffect(e2)
	-- ③：没有超量素材的这张卡被效果破坏送去墓地的场合发动。这张卡作为超量素材，从额外卡组把1只「No.92 伪骸神龙 心地心龙」当作超量召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23998625,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c23998625.spcon)
	e3:SetTarget(c23998625.sptg)
	e3:SetOperation(c23998625.spop)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为53
aux.xyz_number[23998625]=53
-- 设置攻击上升效果的目标为攻击怪兽
function c23998625.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前攻击怪兽设为连锁处理对象
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 若满足条件则使自身攻击力上升攻击怪兽的原本攻击力数值
function c23998625.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理对象（即攻击怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup()
		and tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		local atk=tc:GetBaseAttack()
		-- 使自身攻击力上升指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足代替破坏条件
function c23998625.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
-- 判断是否满足特殊召唤条件（被效果破坏且无超量素材）
function c23998625.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
		and c:GetPreviousOverlayCountOnField()==0 and c:IsLocation(LOCATION_GRAVE)
end
-- 过滤函数，用于筛选可作为XYZ素材的额外卡组怪兽
function c23998625.spfilter(c,e,tp)
	return c:IsCode(97403510) and e:GetHandler():IsCanBeXyzMaterial(c)
		-- 检查目标怪兽是否可以特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤效果的处理信息
function c23998625.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的素材条件
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c23998625.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
-- 执行特殊召唤操作
function c23998625.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤前提条件
	if not c:IsRelateToEffect(e) or not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 从额外卡组中检索符合条件的怪兽
	local tc=Duel.GetFirstMatchingCard(c23998625.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tc then
		local cg=Group.FromCards(c)
		tc:SetMaterial(cg)
		-- 将自身作为超量素材叠放至目标怪兽上
		Duel.Overlay(tc,cg)
		-- 以XYZ召唤方式将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
