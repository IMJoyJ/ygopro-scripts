--サイバー・ドラゴン・インフィニティ
-- 效果：
-- 机械族·光属性6星怪兽×3
-- 「电子龙·无限」1回合1次也能在自己场上的「电子龙·新星」上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：1回合1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
-- ③：1回合1次，魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c10443957.initial_effect(c)
	aux.AddXyzProcedure(c,c10443957.mfilter,6,3,c10443957.ovfilter,aux.Stringid(10443957,0),3,c10443957.xyzop)  --"是否在「电子龙·新星」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10443957.atkval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10443957.target)
	e2:SetOperation(c10443957.operation)
	c:RegisterEffect(e2)
	-- ③：1回合1次，魔法·陷阱·怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c10443957.discon)
	e3:SetCost(c10443957.discost)
	e3:SetTarget(c10443957.distg)
	e3:SetOperation(c10443957.disop)
	c:RegisterEffect(e3)
end
-- 筛选超量召唤素材：必须是机械族且光属性的怪兽。
function c10443957.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 筛选可以重叠超量召唤的对象：表侧表示且卡号为58069384的「电子龙·新星」。
function c10443957.ovfilter(c)
	return c:IsFaceup() and c:IsCode(58069384)
end
-- 处理「电子龙·无限」在「电子龙·新星」上重叠来超量召唤的附加条件：确认本回合未使用过该方式；实际使用时登记本回合的誓约标记。
function c10443957.xyzop(e,tp,chk)
	-- 条件检查阶段：确认玩家本回合没有对应的誓约标记，即本回合还未使用这种特殊召唤方式。
	if chk==0 then return Duel.GetFlagEffect(tp,10443957)==0 end
	-- 为玩家注册一个持续到结束阶段的誓约标记，记录本回合已使用过在「电子龙·新星」上重叠来超量召唤的方式，防止同一回合再次使用。
	Duel.RegisterFlagEffect(tp,10443957,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 计算这张卡的攻击力上升值：超量素材数量×200。
function c10443957.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 筛选效果对象：场上表侧攻击表示且可以作为超量素材的怪兽。
function c10443957.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanOverlay()
end
-- ②效果发动时选择对象：确认自身是超量怪兽，并从双方场上选择1只表侧攻击表示怪兽（不能选择自身）作为对象。
function c10443957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10443957.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 判定场上是否存在至少1只满足条件的表侧攻击表示怪兽可供选择作为对象。
		and Duel.IsExistingTarget(c10443957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 给玩家显示选择提示：请选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从双方场上选择1只符合条件的表侧攻击表示怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c10443957.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ②效果处理：若这张卡和对象怪兽仍与效果关联且对象不免疫效果，则将对象怪兽作为这张卡的超量素材；若对象怪兽原本有超量素材，先将其素材送去墓地。
function c10443957.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对象怪兽原本持有的超量素材以规则原因全部送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对象怪兽叠放在这张卡下面，作为这张卡的超量素材。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- ③效果的发动条件：这张卡未被战斗破坏，且当前连锁的发动可以被无效。
function c10443957.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自身不处于战斗破坏状态，且当前连锁的卡牌效果发动能够被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ③效果的发动代价：检查并取除这张卡1个超量素材。
function c10443957.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果发动时的目标与处理设定：无条件允许发动，并设定无效并破坏的操作信息。
function c10443957.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定操作信息：本次连锁要无效的对象是发动中的那张卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动中的卡可破坏且仍与效果关联，追加设定破坏该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：无效该发动，并破坏那张卡。
function c10443957.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效该连锁的发动，且该卡仍与效果关联，则继续处理破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏被无效发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
