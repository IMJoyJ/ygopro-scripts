--破壊剣の使い手－バスター・ブレイダー
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「破坏之剑士」使用。
-- ②：对方场上的怪兽被战斗·效果破坏送去墓地的场合，以破坏的那1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ③：1回合1次，把这张卡装备的1张怪兽卡送去墓地才能发动。和送去墓地的那张怪兽卡相同种族的对方场上的怪兽全部破坏。
function c3428069.initial_effect(c)
	-- 效果①：这张卡的卡名只要在场上·墓地存在当作「破坏之剑士」（78193831）使用。
	aux.EnableChangeCode(c,78193831,LOCATION_MZONE+LOCATION_GRAVE)
	-- 效果②：对方场上的怪兽被战斗·效果破坏送去墓地的场合，以破坏的那1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
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
	-- 效果③：1回合1次，把这张卡装备的1张怪兽卡送去墓地才能发动。和送去墓地的那张怪兽卡相同种族的对方场上的怪兽全部破坏。
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
-- 筛选满足②发动条件的怪兽：对方场上的怪兽因战斗或效果被破坏后存在于墓地，且可作为效果对象、不属于禁止卡。
function c3428069.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
-- 取对象效果的目标判定：若指定对象，则检查该对象是否在此次被破坏的怪兽组中且满足筛选条件；若进行发动判定，则检查魔陷区是否有空位且怪兽组中存在满足条件的对象。
function c3428069.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c3428069.filter(chkc,e,tp) end
	-- 检查我方魔陷区是否有空位，用于装备被破坏的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and eg:IsExists(c3428069.filter,1,nil,e,tp) end
	local g=eg:Filter(c3428069.filter,nil,e,tp)
	local tc=nil
	if g:GetCount()>1 then
		-- 弹出发动时选择对象的提示消息“请选择效果的对象”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	-- 将选择的怪兽设置为当前连锁的处理对象（取对象）。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，标明该效果涉及对象从墓地离开（被装备），用于应对王家长眠之谷等影响墓地移动的效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果②处理：若发动者仍与此效果相关且表侧表示、对象仍与此效果相关，则将对象作为装备卡装备给发动者，并给该装备卡设置只能装备给发动者的限制。
function c3428069.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡，即被破坏的那1只怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 执行装备操作：将对象卡作为装备卡装备给本卡；若装备失败则直接终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 效果②中“那只怪兽当作装备卡使用给这张卡装备”的实现：为装备卡设置装备限制效果，使其只能装备给这张卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3428069.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数：判定当前装备对象是否是效果的持有者（即这张「破坏之剑士」），只有该卡才能装备此装备卡。
function c3428069.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ③效果的代价筛选：装备怪兽卡必须能作为代价送去墓地，且对方场上有与该装备怪兽相同种族的表侧表示怪兽存在。
function c3428069.tgfilter(c,tp)
	return c:IsAbleToGraveAsCost()
		-- 检查对方场上是否存在与候选装备怪兽相同种族的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c3428069.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace())
end
-- 破坏对象筛选：对方场上的表侧表示怪兽，且种族与所指定的种族相同。
function c3428069.desfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- ③效果的代价处理：先检查自己装备区是否有符合条件的装备怪兽可作为代价；然后提示玩家选择要送去墓地的装备怪兽；记录其种族；最后将选择的装备怪兽送去墓地作为代价。
function c3428069.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c3428069.tgfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的装备怪兽卡（作为代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c3428069.tgfilter,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetRace())
	-- 将选择的装备怪兽卡送去墓地，作为发动③效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果的目标判定：发动时无其他需要指定对象，直接记录操作信息；取得对方场上与记录种族相同的表侧表示怪兽组，并设置破坏信息。
function c3428069.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得对方场上所有与记录种族相同的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c3428069.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置操作信息，表示本次效果将破坏这些怪兽，数量为取得的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果处理：再次取得对方场上符合条件的怪兽组，并以效果原因将它们全部破坏。
function c3428069.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上与记录种族相同的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c3428069.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 以效果原因（REASON_EFFECT）破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
