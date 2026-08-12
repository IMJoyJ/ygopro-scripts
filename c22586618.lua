--ダークネス・シムルグ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己对暗属性或者风属性的怪兽的上级召唤成功的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
-- ③：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放才能发动。那个发动无效并破坏。
function c22586618.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己对暗属性或者风属性的怪兽的上级召唤成功的场合才能发动。这张卡特殊召唤。
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
	-- ③：魔法·陷阱卡的效果发动时，把自己场上1只鸟兽族·风属性怪兽解放才能发动。那个发动无效并破坏。
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
-- 过滤满足上级召唤且为暗属性或风属性的召唤怪兽
function c22586618.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_WIND)
end
-- 检查是否有满足条件的怪兽被上级召唤成功
function c22586618.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22586618.cfilter,1,nil,tp)
end
-- 判断是否满足特殊召唤的条件
function c22586618.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c22586618.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足无效发动的条件
function c22586618.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认该效果未在战斗中被破坏且发动的是魔法或陷阱效果
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤满足鸟兽族且风属性的场上怪兽
function c22586618.costfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查并选择满足条件的怪兽进行解放作为代价
function c22586618.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可被解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22586618.costfilter,1,nil,tp) end
	-- 选择一张满足条件的怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c22586618.costfilter,1,1,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(sg,REASON_COST)
end
-- 设置无效发动和破坏的处理信息
function c22586618.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置发动无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏的处理信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效发动和破坏操作
function c22586618.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动并确认目标卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
