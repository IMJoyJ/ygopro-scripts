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
-- 筛选可作为①效果发动代价除外的装备魔法卡：该卡位于墓地、场上表侧表示或作为装备卡存在，且类型为装备魔法卡，并能作为代价除外。
function c22091647.costfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() or c:GetEquipTarget())
		and (c:GetType()&(TYPE_EQUIP+TYPE_SPELL))==TYPE_EQUIP+TYPE_SPELL
		and c:IsAbleToRemoveAsCost()
end
-- ①效果的cost处理：确认存在符合条件的装备魔法卡；提示玩家选择要除外的卡；从自己的场上·墓地选择1张装备魔法卡；将其表侧除外作为发动代价。
function c22091647.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认自己的场上·墓地存在至少1张满足costfilter条件的装备魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22091647.costfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送“请选择要除外的卡”的提示消息，用于选择代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的场上·墓地区域选择1张满足costfilter的装备魔法卡，作为①效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c22091647.costfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为①效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标检查与登记：确认自己主要怪兽区有空位且此卡可以被特殊召唤，并登记特殊召唤的操作信息。
function c22091647.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上主要怪兽区存在可用的空格，以判断能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作将把此卡特殊召唤（CATEGORY_SPECIAL_SUMMON），供其他效果或规则检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与效果相关，则将其从手卡特殊召唤到自己场上。
function c22091647.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：攻击怪兽是此卡，且当前没有通过②效果装备着的怪兽（或已有装备已失效），满足这些条件才可发动。
function c22091647.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 判断攻击者是否为此卡，并且此前记录的装备怪兽标签为空或已不再持有对应flag（即可重新装备）。
	return Duel.GetAttacker()==e:GetHandler() and (ec==nil or ec:GetFlagEffect(22091647)==0)
end
-- 筛选可作为②效果装备对象的怪兽：表侧表示，且为自己控制或能够转移控制权（以装备到自己魔陷区）。
function c22091647.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- ②效果发动前检查：自己魔陷区有空位，且场上存在此卡以外满足装备条件的表侧表示怪兽。
function c22091647.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己魔陷区存在可用的空格，以决定能否将怪兽作为装备卡放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认场上存在此卡以外、满足条件（表侧且可控/可转移控制权）的怪兽可作为装备对象。
		and Duel.IsExistingMatchingCard(c22091647.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
end
-- ②效果处理：若魔陷区无空位、此卡已里侧或不再与效果相关则终止；否则选择1只怪兽装备给此卡，赋予攻击力+500，设置装备限制与标记，使其只能装备给此卡且只能装备1只。
function c22091647.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再次确认自己魔陷区有空位，若没有则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家发送“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择此卡以外、满足条件的1只表侧表示怪兽，作为要装备的卡。
	local g=Duel.SelectMatchingCard(tp,c22091647.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e),tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽作为装备卡装备给此卡；若装备失败则中止处理。
		if not Duel.Equip(tp,tc,c) then return end
		tc:RegisterFlagEffect(22091647,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- （只有1只可以装备）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c22091647.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 当作攻击力上升500的装备卡使用
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 定义装备限制：这张装备卡只能装备给效果所有者（即此卡），不能转装备给其他怪兽。
function c22091647.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ③效果的发动条件：此卡未被战斗破坏，且正在发动的效果为怪兽效果，并且该连锁可以被无效。
function c22091647.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡未被战斗破坏、当前连锁的效果是怪兽效果且该发动可被无效化。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 筛选可作为③效果代价的卡：自己场上表侧表示的装备卡，且可以作为代价送去墓地。
function c22091647.costfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- ③效果的cost处理：确认存在可送墓的表侧装备卡；提示玩家选择；选择1张；将其送去墓地作为发动代价。
function c22091647.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认自己场上有满足条件的表侧表示装备卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c22091647.costfilter2,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张表侧表示装备卡，作为③效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c22091647.costfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地，作为③效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果的目标设置：本效果不取对象；登记将无效该怪兽效果的发动，并在可破坏时登记破坏该怪兽。
function c22091647.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将连锁中的那次效果（eg）设为无效对象（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该效果的发动的怪兽可被破坏且仍与效果相关，则追加登记破坏该怪兽（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：无效那次怪兽效果的发动；若发动的怪兽仍与效果相关，则将其破坏。
function c22091647.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁发动；若无效成功且发动效果的怪兽仍与效果相关，才执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的怪兽以效果破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
