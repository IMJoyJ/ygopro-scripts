--アサルト・アーマー
-- 效果：
-- 自己场上的怪兽只有战士族怪兽1只的场合才能给那只怪兽装备。
-- ①：装备怪兽的攻击力上升300。
-- ②：把装备的这张卡送去墓地才能发动。这个回合，这张卡装备过的怪兽在同1次的战斗阶段中可以作2次攻击。
function c88190790.initial_effect(c)
	-- 自己场上的怪兽只有战士族怪兽1只的场合才能给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCondition(c88190790.condition)
	e1:SetTarget(c88190790.target)
	e1:SetOperation(c88190790.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 自己场上的怪兽只有战士族怪兽1只的场合才能给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c88190790.eqlimit)
	c:RegisterEffect(e3)
	-- ②：把装备的这张卡送去墓地才能发动。这个回合，这张卡装备过的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88190790,0))  --"多次攻击"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c88190790.macon)
	e4:SetCost(c88190790.macost)
	e4:SetOperation(c88190790.maop)
	c:RegisterEffect(e4)
end
-- 定义装备限制：仅在自己场上只有1只战士族怪兽且为该怪兽时可以装备（或已装备时保持装备状态）。
function c88190790.eqlimit(e,c)
	if e:GetHandler():GetEquipTarget()==c then return true end
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	local tc=g:GetFirst()
	return g:GetCount()==1 and tc==c and tc:IsRace(RACE_WARRIOR)
end
-- 判断发动条件：自己场上的怪兽是否只有战士族怪兽1只，并记录该怪兽。
function c88190790.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return g:GetCount()==1 and tc:IsFaceup() and tc:IsRace(RACE_WARRIOR)
end
-- 选择满足条件的1只怪兽作为装备对象，并设置装备操作信息。
function c88190790.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc==tc end
	if chk==0 then return tc and tc:IsCanBeEffectTarget(e) end
	-- 将目标怪兽设置为当前连锁的效果处理对象。
	Duel.SetTargetCard(tc)
	-- 设置当前连锁的操作信息为装备此卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备效果：在条件满足时将这张卡装备给目标怪兽。
function c88190790.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 获取当前连锁的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if ct==1 and e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断②效果的发动条件：当前回合玩家能够进入战斗阶段。
function c88190790.macon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 执行②效果的发动代价：将装备的这张卡送去墓地，并记录被装备的怪兽。
function c88190790.macost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡装备着的怪兽设置为当前连锁的效果处理对象。
	Duel.SetTargetCard(c:GetEquipTarget())
	-- 作为发动代价，将这张卡送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 执行②效果的效果处理：使目标怪兽获得在同一次战斗阶段中可以作2次攻击的效果。
function c88190790.maop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取曾装备过这张卡的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这个回合，这张卡装备过的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
