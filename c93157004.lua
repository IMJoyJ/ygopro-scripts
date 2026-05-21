--ヴァイロン・オメガ
-- 效果：
-- 调整2只＋调整以外的名字带有「大日」的怪兽1只
-- 这张卡同调召唤成功时，场上表侧表示存在的通常召唤的怪兽全部破坏。1回合1次，可以选择自己墓地存在的1只名字带有「大日」的怪兽当作装备卡使用给这张卡装备。效果怪兽的效果发动时，可以把这张卡装备的1张装备卡送去墓地让那个发动无效并破坏。
function c93157004.initial_effect(c)
	-- 添加同调召唤手续：调整2只＋调整以外的名字带有「大日」的怪兽1只
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.NonTuner(Card.IsSetCard,0x30),1,1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，场上表侧表示存在的通常召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93157004,0))  --"通常召唤的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c93157004.descon)
	e2:SetTarget(c93157004.destg)
	e2:SetOperation(c93157004.desop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择自己墓地存在的1只名字带有「大日」的怪兽当作装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93157004,1))  --"装备"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c93157004.eqtg)
	e3:SetOperation(c93157004.eqop)
	c:RegisterEffect(e3)
	-- 效果怪兽的效果发动时，可以把这张卡装备的1张装备卡送去墓地让那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93157004,2))  --"效果怪兽的效果发动无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c93157004.discon)
	e4:SetCost(c93157004.discost)
	e4:SetTarget(c93157004.distg)
	e4:SetOperation(c93157004.disop)
	c:RegisterEffect(e4)
	-- （系统效果：用于与「大日元素」的效果进行联动）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(21142671)
	c:RegisterEffect(e5)
end
-- 检查此卡是否成功进行同调召唤
function c93157004.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤场上表侧表示存在的通常召唤的怪兽
function c93157004.desfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 设置破坏效果的操作信息：破坏场上所有表侧表示存在的通常召唤的怪兽
function c93157004.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上表侧表示存在的通常召唤的怪兽
	local g=Duel.GetMatchingGroup(c93157004.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：获取并破坏场上所有表侧表示存在的通常召唤的怪兽
function c93157004.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上表侧表示存在的通常召唤的怪兽
	local g=Duel.GetMatchingGroup(c93157004.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏这些怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以作为装备卡的名字带有「大日」的怪兽
function c93157004.eqfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动准备：检查魔法与陷阱区域是否有空位，以及墓地中是否存在可装备的「大日」怪兽
function c93157004.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己墓地是否存在可以作为效果对象的「大日」怪兽
		and Duel.IsExistingTarget(c93157004.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只名字带有「大日」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93157004.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：使选中的卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的处理：将选中的墓地怪兽作为装备卡装备给此卡，并添加装备限制
function c93157004.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽作为装备卡装备给此卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c93157004.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 限制该装备卡只能装备给此卡（效果的拥有者）
function c93157004.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 检查发动无效效果的条件：此卡未在战斗中被破坏、发动的效果是怪兽效果，且该发动可以被无效
function c93157004.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		-- 并且该连锁的发动可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 发动无效效果的消耗（Cost）：将此卡装备的1张装备卡送去墓地
function c93157004.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(Card.IsAbleToGraveAsCost,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsAbleToGraveAsCost,1,1,nil)
	-- 将选中的装备卡作为发动Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动无效效果的发动准备：设置无效与破坏的操作信息
function c93157004.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动无效效果的处理：使该发动无效并破坏该卡
function c93157004.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该发动无效，且该卡在连锁中关系成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
