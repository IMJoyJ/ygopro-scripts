--ゴッドフェニックス・ギア・フリード
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己的场上·墓地把1张装备魔法卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡攻击的伤害步骤开始时才能发动。选这张卡以外的场上1只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备（只有1只可以装备）。
-- ③：怪兽的效果发动时，把自己场上1张表侧表示的装备卡送去墓地才能发动。那个发动无效并破坏。
function c22091647.initial_effect(c)
	-- ①：从自己的场上·墓地把1张装备魔法卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22091647,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22091647)
	e1:SetCost(c22091647.spcost)
	e1:SetTarget(c22091647.sptg)
	e1:SetOperation(c22091647.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的伤害步骤开始时才能发动。选这张卡以外的场上1只表侧表示怪兽当作攻击力上升500的装备卡使用给这张卡装备（只有1只可以装备）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22091647,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,22091648)
	e2:SetCondition(c22091647.eqcon)
	e2:SetTarget(c22091647.eqtg)
	e2:SetOperation(c22091647.eqop)
	c:RegisterEffect(e2)
	-- ③：怪兽的效果发动时，把自己场上1张表侧表示的装备卡送去墓地才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22091647,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,22091649)
	e3:SetCondition(c22091647.negcon)
	e3:SetCost(c22091647.negcost)
	e3:SetTarget(c22091647.negtg)
	e3:SetOperation(c22091647.negop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的装备魔法卡（在场上或墓地且可除外）
function c22091647.costfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() or c:GetEquipTarget())
		and (c:GetType()&(TYPE_EQUIP+TYPE_SPELL))==TYPE_EQUIP+TYPE_SPELL
		and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的装备魔法卡可作为除外费用
function c22091647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的装备魔法卡可作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(c22091647.costfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c22091647.costfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断是否可以将此卡特殊召唤
function c22091647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c22091647.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足装备效果发动条件
function c22091647.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 判断是否为攻击怪兽且未装备过
	return Duel.GetAttacker()==e:GetHandler() and (ec==nil or ec:GetFlagEffect(22091647)==0)
end
-- 筛选可装备的怪兽
function c22091647.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 判断是否满足装备效果发动条件
function c22091647.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否有满足条件的怪兽可装备
		and Duel.IsExistingMatchingCard(c22091647.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
end
-- 执行装备操作
function c22091647.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否有足够的装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽进行装备
	local g=Duel.SelectMatchingCard(tp,c22091647.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e),tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将怪兽装备给此卡
		if not Duel.Equip(tp,tc,c) then return end
		tc:RegisterFlagEffect(22091647,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 设置装备限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c22091647.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 设置装备后攻击力上升500的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数
function c22091647.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断是否满足无效效果发动条件
function c22091647.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡未在战斗中被破坏且对方发动的是怪兽效果
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 检索满足条件的装备卡（场上表侧表示且可送墓）
function c22091647.costfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 检查是否有满足条件的装备卡可作为送墓费用
function c22091647.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的装备卡可作为送墓费用
	if chk==0 then return Duel.IsExistingMatchingCard(c22091647.costfilter2,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的装备卡
	local g=Duel.SelectMatchingCard(tp,c22091647.costfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置无效效果的操作信息
function c22091647.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效效果和破坏操作
function c22091647.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效效果并确认目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效效果影响的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
