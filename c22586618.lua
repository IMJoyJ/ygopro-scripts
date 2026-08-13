--ダークネス・シムルグ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己对暗属性或者风属性的怪兽的上级召唤成功的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
-- ③：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放才能发动。那个发动无效并破坏。
function c22586618.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡在手卡·墓地存在，自己对暗属性或者风属性的怪兽的上级召唤成功的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22586618,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,22586618)
	e1:SetCondition(c22586618.spcon)
	e1:SetTarget(c22586618.sptg)
	e1:SetOperation(c22586618.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22586618,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,22586619)
	e3:SetCondition(c22586618.negcon)
	e3:SetCost(c22586618.negcost)
	e3:SetTarget(c22586618.negtg)
	e3:SetOperation(c22586618.negop)
	c:RegisterEffect(e3)
end
-- 判断成功上级召唤的怪兽是否为玩家tp召唤的暗属性或风属性怪兽（作为①效果的触发条件）。
function c22586618.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_WIND)
end
-- ①效果的发动条件：本次上级召唤成功的怪兽组中存在至少1只满足cfilter条件的怪兽。
function c22586618.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22586618.cfilter,1,nil,tp)
end
-- ①效果发动时判定：确认己方怪兽区域有空位，且这张卡自身可被特殊召唤。
function c22586618.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认己方主要怪兽区域存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记将这张卡特殊召唤的操作信息（用于后续连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function c22586618.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到tp的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：这张卡不处于战斗破坏确定状态，且发动连锁的效果为魔法·陷阱卡效果，并且该连锁的发动可以被无效。
function c22586618.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定本卡不是战斗破坏确定状态，且触发连锁的效果是魔法·陷阱卡效果，且连锁可被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 筛选可解放的鸟兽族·风属性怪兽：必须是鸟兽族、风属性，且控制者为己方或表侧表示。
function c22586618.costfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and (c:IsControler(tp) or c:IsFaceup())
end
-- ③效果发动时支付代价：选择并解放己方场上1只鸟兽族·风属性怪兽。
function c22586618.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认己方场上存在至少1只满足解放条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22586618.costfilter,1,nil,tp) end
	-- 选择1只满足条件的鸟兽族·风属性怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c22586618.costfilter,1,1,nil,tp)
	-- 将选择的怪兽解放（作为发动③效果的代价）。
	Duel.Release(sg,REASON_COST)
end
-- ③效果的目标处理：无对象效果，登记使该魔法·陷阱卡发动无效，并视情况登记破坏。
function c22586618.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记将连锁中的那张魔法·陷阱卡发动无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该魔法·陷阱卡可被破坏且与效果关联，则登记将其破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：使该魔法·陷阱卡的发动无效，并若该卡仍与效果关联则将其破坏。
function c22586618.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动无效是否成功，且被无效的卡仍与连锁效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效的魔法·陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
