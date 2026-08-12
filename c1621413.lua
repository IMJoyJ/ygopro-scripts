--ダーク・レクイエム・エクシーズ・ドラゴン
-- 效果：
-- 5星怪兽×3
-- ①：这张卡有「暗叛逆超量龙」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
-- ●对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选自己墓地1只超量怪兽特殊召唤。
function c1621413.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为5、数量为3的怪兽作为超量素材
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1621413,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c1621413.atkcon)
	e1:SetCost(c1621413.cost)
	e1:SetTarget(c1621413.atktg)
	e1:SetOperation(c1621413.atkop)
	c:RegisterEffect(e1)
	-- ●对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选自己墓地1只超量怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1621413,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1621413.discon)
	e2:SetCost(c1621413.cost)
	e2:SetTarget(c1621413.distg)
	e2:SetOperation(c1621413.disop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否含有「暗叛逆超量龙」作为超量素材
function c1621413.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
-- 支付1个超量素材作为cost
function c1621413.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标为对方场上的1只表侧表示怪兽
function c1621413.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置效果目标为对方场上的1只表侧表示怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 判断对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为目标
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果：将目标怪兽攻击力设为0，并使自身攻击力上升该数值
function c1621413.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetBaseAttack()
		-- 将目标怪兽的攻击力设为0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 使自身攻击力上升目标怪兽的原本攻击力数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			c:RegisterEffect(e2)
		end
	end
end
-- 判断是否满足发动条件：此卡未在战斗中被破坏、对方发动怪兽效果、连锁可被无效、此卡含有「暗叛逆超量龙」作为超量素材
function c1621413.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方发动怪兽效果且该连锁可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
-- 设置效果处理信息：使发动无效并可能破坏目标怪兽
function c1621413.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息：破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤满足条件的墓地超量怪兽用于特殊召唤
function c1621413.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果：使对方怪兽效果无效并破坏，之后可从墓地特殊召唤1只超量怪兽
function c1621413.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使对方效果无效并破坏目标怪兽
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 判断己方场上是否有空位进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取满足条件的墓地超量怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c1621413.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有满足条件的墓地超量怪兽且玩家选择特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1621413,2)) then  --"是否选怪兽特殊召唤？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
