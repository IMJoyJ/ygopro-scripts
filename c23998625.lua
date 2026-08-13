--No.53 偽骸神 Heart－eartH
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，这张卡被选择作为攻击对象的场合发动。这张卡的攻击力直到回合结束时上升那只攻击怪兽的原本攻击力数值。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
-- ③：没有超量素材的这张卡被效果破坏送去墓地的场合发动。这张卡作为超量素材，从额外卡组把1只「No.92 伪骸神龙 心地心龙」当作超量召唤作特殊召唤。
function c23998625.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用任意3只5星怪兽叠放进行超量召唤（5星怪兽×3）。
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
-- 将这张卡的No.编号登记为53，使其在No.相关效果中视为No.53。
aux.xyz_number[23998625]=53
-- ①效果发动时的合法判断：被选为攻击对象后必发，发动时将攻击怪兽设为效果处理的对象。
function c23998625.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前攻击的怪兽设置为效果的对象（对应“那只攻击怪兽”）。
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果处理：若此卡与对象怪兽仍与效果相关且此卡表侧表示、攻击怪兽可攻击且攻击未被取消，则用攻击怪兽的原本攻击力让此卡攻击力上升，持续到回合结束。
function c23998625.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果对象怪兽（攻击怪兽）的引用。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup()
		and tc:IsRelateToEffect(e) and tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		local atk=tc:GetBaseAttack()
		-- 这张卡的攻击力直到回合结束时上升那只攻击怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 代替破坏的发动条件：此卡有超量素材可取除、此次破坏原因为战斗或效果，且不是由代替效果造成的破坏。
function c23998625.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动“取除1个超量素材代替破坏”的效果，选择是则执行后续代替处理。
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
-- ③效果的发动条件：此卡在场上被效果破坏、破坏时没有超量素材，并且被送去墓地时满足。
function c23998625.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
		and c:GetPreviousOverlayCountOnField()==0 and c:IsLocation(LOCATION_GRAVE)
end
-- 筛选特殊召唤对象：必须是「No.92 伪骸神龙 心地心龙」，此卡（No.53）可作为其超量素材，且该No.92能被当作超量召唤特殊召唤并有可用区域。
function c23998625.spfilter(c,e,tp)
	return c:IsCode(97403510) and e:GetHandler():IsCanBeXyzMaterial(c)
		-- 确认「No.92」可以进行超量召唤方式的特殊召唤，且额外卡组怪兽可出场的区域有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ③效果的目标与合法性检查：确认此卡可作为超量素材，且额外卡组存在符合条件的「No.92」；随后设置特殊召唤与离开墓地的操作信息。
function c23998625.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否受“必须作为超量素材”的限制且当前可满足，作为发动前提。
	if chk==0 then return aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的「No.92 伪骸神龙 心地心龙」。
		and Duel.IsExistingMatchingCard(c23998625.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果操作信息：本次处理将进行特殊召唤，从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果操作信息：此卡将离开墓地（作为超量素材重叠到No.92下），供相关连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
-- 效果处理：若此卡仍与效果关联且满足素材限制，则从额外卡组选择1只「No.92」，将此卡作为素材叠放，将其当作超量召唤特殊召唤并完成超量召唤手续。
function c23998625.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再次确认此卡仍与效果关联且能够作为超量素材，否则中止处理。
	if not c:IsRelateToEffect(e) or not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 从额外卡组取1张符合条件的「No.92 伪骸神龙 心地心龙」。
	local tc=Duel.GetFirstMatchingCard(c23998625.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tc then
		local cg=Group.FromCards(c)
		tc:SetMaterial(cg)
		-- 将包含此卡在内的素材组叠放到「No.92」下方，使其成为超量素材。
		Duel.Overlay(tc,cg)
		-- 将「No.92」以超量召唤方式表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
