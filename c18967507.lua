--鎧獄竜－サイバー・ダークネス・ドラゴン
-- 效果：
-- 「电子暗黑」效果怪兽×5
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己墓地选1只龙族怪兽或者机械族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
function c18967507.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用5个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c18967507.matfilter,5,true)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c18967507.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合才能发动。从自己墓地选1只龙族怪兽或者机械族怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18967507,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c18967507.eqtg)
	e2:SetOperation(c18967507.eqop)
	c:RegisterEffect(e2)
	-- ③：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18967507,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c18967507.negcon)
	e3:SetCost(c18967507.negcost)
	e3:SetTarget(c18967507.negtg)
	e3:SetOperation(c18967507.negop)
	c:RegisterEffect(e3)
end
-- 融合素材必须是效果怪兽且属于「电子暗黑」系列
function c18967507.matfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFusionSetCard(0x4093)
end
-- 限制该卡不能通过非融合方式特殊召唤
function c18967507.splimit(e,se,sp,st)
	-- 若该卡不在额外卡组则不能通过非融合方式特殊召唤
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 装备卡过滤函数，筛选龙族或机械族且未被禁止的怪兽
function c18967507.eqfilter(c,tp)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果发动时判断是否满足条件：场上存在装备区域且墓地存在符合条件的装备卡
function c18967507.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否受到64753988效果影响，决定装备卡检索位置
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 判断场上是否存在装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在符合条件的装备卡
		and Duel.IsExistingMatchingCard(c18967507.eqfilter,tp,LOCATION_GRAVE,loc,1,nil,tp) end
	-- 设置操作信息，表示将有1张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 装备卡效果处理函数，执行装备操作并设置装备限制与攻击力加成
function c18967507.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否存在装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 判断是否受到64753988效果影响，决定装备卡检索位置
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从墓地选择符合条件的装备卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c18967507.eqfilter),tp,LOCATION_GRAVE,loc,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将装备卡装备给目标怪兽
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备限制效果，确保装备卡只能装备给该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c18967507.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetBaseAttack()
		if atk>0 then
			-- 设置装备卡攻击力加成效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 装备限制函数，确保装备卡只能装备给拥有者
function c18967507.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果发动条件函数，判断是否满足无效发动的条件
function c18967507.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若该卡未在战斗中被破坏且发动者不是自己且连锁可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
-- 无效发动的装备卡过滤函数
function c18967507.negfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 无效发动时的费用支付函数，选择场上一张装备卡送去墓地
function c18967507.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在符合条件的装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18967507.negfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上一张符合条件的装备卡
	local g=Duel.SelectMatchingCard(tp,c18967507.negfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的装备卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置无效发动时的操作信息
function c18967507.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效发动并破坏对应卡
function c18967507.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效发动成功且发动卡仍存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
