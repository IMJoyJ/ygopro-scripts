--破壊剣の使い手－バスター・ブレイダー
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「破坏之剑士」使用。
-- ②：对方场上的怪兽被战斗·效果破坏送去墓地的场合，以破坏的那1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ③：1回合1次，把这张卡装备的1张怪兽卡送去墓地才能发动。和送去墓地的那张怪兽卡相同种族的对方场上的怪兽全部破坏。
function c3428069.initial_effect(c)
	-- 使该卡在场上和墓地存在时视为「破坏之剑士」
	aux.EnableChangeCode(c,78193831,LOCATION_MZONE+LOCATION_GRAVE)
	-- 对方场上的怪兽被战斗·效果破坏送去墓地的场合，以破坏的那1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3428069,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetTarget(c3428069.eqtg)
	e2:SetOperation(c3428069.eqop)
	c:RegisterEffect(e2)
	-- 1回合1次，把这张卡装备的1张怪兽卡送去墓地才能发动。和送去墓地的那张怪兽卡相同种族的对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3428069,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c3428069.descost)
	e3:SetTarget(c3428069.destg)
	e3:SetOperation(c3428069.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断被破坏的怪兽是否满足装备条件（怪兽类型、位置、控制权、破坏原因等）
function c3428069.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
-- 设置效果目标，检查是否有满足条件的怪兽可作为对象
function c3428069.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c3428069.filter(chkc,e,tp) end
	-- 检查场上是否有足够的魔法陷阱区域来装备怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and eg:IsExists(c3428069.filter,1,nil,e,tp) end
	local g=eg:Filter(c3428069.filter,nil,e,tp)
	local tc=nil
	if g:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	-- 设置当前连锁效果的目标卡片
	Duel.SetTargetCard(tc)
	-- 设置操作信息，标记将要离开墓地的卡片
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 装备怪兽到自身，若成功则注册装备限制效果
function c3428069.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽装备到自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 注册装备限制效果，确保只有自身能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3428069.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保只有自身能装备该怪兽
function c3428069.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤函数，用于判断装备的怪兽是否满足送去墓地并能触发破坏效果的条件
function c3428069.tgfilter(c,tp)
	return c:IsAbleToGraveAsCost()
		-- 检查是否存在与送去墓地的怪兽种族相同的对方场上怪兽
		and Duel.IsExistingMatchingCard(c3428069.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace())
end
-- 过滤函数，用于判断对方场上是否满足种族条件的怪兽
function c3428069.desfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 设置效果发动的费用，选择一张装备怪兽送去墓地作为代价
function c3428069.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c3428069.tgfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的装备怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c3428069.tgfilter,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetRace())
	-- 将选中的装备怪兽送去墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置破坏效果的目标，获取所有满足种族条件的对方场上怪兽
function c3428069.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取所有满足种族条件的对方场上怪兽
	local g=Duel.GetMatchingGroup(c3428069.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置操作信息，标记将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将所有满足种族条件的对方场上怪兽破坏
function c3428069.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足种族条件的对方场上怪兽
	local g=Duel.GetMatchingGroup(c3428069.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 将所有满足种族条件的对方场上怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
