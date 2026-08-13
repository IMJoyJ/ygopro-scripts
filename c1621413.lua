--ダーク・レクイエム・エクシーズ・ドラゴン
-- 效果：
-- 5星怪兽×3
-- ①：这张卡有「暗叛逆超量龙」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
-- ●对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以选自己墓地1只超量怪兽特殊召唤。
function c1621413.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可以以3只5星怪兽为素材进行XYZ召唤
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡的攻击力上升那个原本攻击力数值。
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
	-- 对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。那之后，可以从自己墓地把1只超量怪兽特殊召唤。
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
-- 发动条件：判定这张卡是否有「暗叛逆超量龙」作为超量素材（即超量素材中存在卡号16195942）
function c1621413.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
-- 发动代价：从这张卡上取除1个超量素材；先检查是否可取除，再实际取除作为cost
function c1621413.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果的目标选择：选择对方场上1只表侧表示且攻击力不为0的怪兽为对象
function c1621413.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时校验对象：必须位于对方怪兽区、控制者为对方、表侧表示且攻击力不为0
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动合法性检查：对方场上是否存在至少1只表侧表示且攻击力不为0的怪兽，否则不能发动
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择表侧表示怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示且攻击力不为0的怪兽，并设置为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽的攻击力变成0，并使这张卡的攻击力上升对象怪兽的原本攻击力数值
function c1621413.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetBaseAttack()
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力上升那个原本攻击力数值
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
-- 发动条件：对方发动怪兽效果且该发动可以被无效，并且这张卡有「暗叛逆超量龙」作为超量素材
function c1621413.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：自己这张卡未被战斗破坏确定，对方（rp）发动怪兽效果，且该连锁可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,16195942)
end
-- 效果发动条件与操作信息：本效果不取对象，只要满足条件即可发动；同时设置无效并破坏对方发动的那只怪兽的信息
function c1621413.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的怪兽效果（eg）作为要被无效的对象
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将对方发动效果的怪兽作为要被破坏的对象（若可破坏且仍与连锁相关）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 墓地特殊召唤的过滤条件：选择自己墓地的超量怪兽，且能够被特殊召唤（满足苏生限制与召唤条件）
function c1621413.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：无效对方怪兽效果的发动并破坏那只怪兽；那之后，可以选择自己墓地1只超量怪兽特殊召唤
function c1621413.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效发动成功，且该怪兽卡仍与连锁相关并已被破坏，则继续处理后续的特殊召唤
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 检查自己怪兽区是否有可用空格；若无则结束处理，不能特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 取得自己墓地中可以特殊召唤的超量怪兽组，并排除受王家长眠之谷影响的卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c1621413.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 当存在可选择的怪兽且玩家选择‘是’时，执行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(1621413,2)) then  --"是否选怪兽特殊召唤？"
			-- 中断当前效果处理，使接下来的特殊召唤视为独立处理，避免错过时点
			Duel.BreakEffect()
			-- 显示‘选择要特殊召唤的怪兽’的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的超量怪兽以表侧攻击表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
