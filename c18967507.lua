--鎧獄竜－サイバー・ダークネス・ドラゴン
-- 效果：
-- 「电子暗黑」效果怪兽×5
-- 这张卡用融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。从自己墓地选1只龙族怪兽或者机械族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：对方把魔法·陷阱·怪兽的效果发动时，把自己场上1张装备卡送去墓地才能发动。那个发动无效并破坏。
function c18967507.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：可以用5只满足 c18967507.matfilter 条件的怪兽作为融合素材进行融合召唤。
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
-- 融合素材的筛选条件：作为素材的怪兽必须是效果怪兽，且属于「电子暗黑」系列。
function c18967507.matfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFusionSetCard(0x4093)
end
-- 特殊召唤限制条件：当此卡位于额外卡组时，只允许通过融合召唤方式特殊召唤；若在其他位置则不受此限制。
function c18967507.splimit(e,se,sp,st)
	-- 判断方式：如果此卡不在额外卡组，则直接允许这次特殊召唤；如果在额外卡组，则必须是通过融合召唤才能特殊召唤。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 装备对象的筛选条件：选择龙族或机械族怪兽，且该卡在场上没有同名卡，并且不是禁止卡。
function c18967507.eqfilter(c,tp)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 发动检测与准备：检查魔陷区是否有空位，以及自己墓地（若「电子暗黑世界」生效则还包含对方墓地）是否存在符合条件的怪兽；若满足则登记该效果涉及墓地移动的操作信息。
function c18967507.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 发动前检查：我方魔陷区是否有空余位置用来放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动前检查：在可选墓地范围内（自己墓地及「电子暗黑世界」适用时的对方墓地）是否存在至少1只符合条件的龙族/机械族怪兽。
		and Duel.IsExistingMatchingCard(c18967507.eqfilter,tp,LOCATION_GRAVE,loc,1,nil,tp) end
	-- 登记操作信息：本效果将把1张卡从墓地移动，用于与「王家长眠之谷」等会影响墓地效果的卡片进行交互。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果处理：先确认魔陷区仍有空位且本卡仍表侧且与效果关联；然后从自己墓地（或对方墓地，若「电子暗黑世界」适用）选择1只符合条件的龙族/机械族怪兽，将其装备给本卡；再给该装备卡添加只能装备给本卡的限制；最后若该怪兽原攻击力大于0，则上升本卡等量攻击力。
function c18967507.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前再次检查我方魔陷区是否有空位，若没有则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 显示选择提示：请玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从墓地（可能包括对方墓地）选择1张符合条件的龙族/机械族怪兽；过滤时排除了受「王家长眠之谷」影响而无法离开墓地的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c18967507.eqfilter),tp,LOCATION_GRAVE,loc,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽作为装备卡装备到这张卡上；若装备不成功则终止后续处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c18967507.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetBaseAttack()
		if atk>0 then
			-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
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
-- 装备限制函数：判断装备卡的拥有者是否为这张卡，即该装备卡只能装备在这张卡上。
function c18967507.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 发动条件：这张卡没有被战斗破坏，且本次发动效果的是对方玩家，且该连锁可以被无效。
function c18967507.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件具体判断：本卡不处于被战斗破坏状态；效果发动方是对方；当前连锁的效果可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
end
-- 代价对象筛选：可作为代价的是表侧表示的装备卡，或正装备在怪兽身上的装备卡，并且可以送去墓地作为代价。
function c18967507.negfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 代价处理：先从自己场上确认是否存在符合条件的装备卡；若存在则选择1张，将其作为代价送入墓地。
function c18967507.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查自己场上是否存在至少1张符合条件的装备卡可供送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c18967507.negfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张符合条件的装备卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c18967507.negfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的装备卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标设置：本效果以当前发动的连锁（对方效果）为对象；登记无效该连锁的发动，并视情况登记破坏发动的那张卡。
function c18967507.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：无效当前连锁的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记操作信息：若对方效果的发动卡可以被破坏，则追加登记破坏该卡的信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：尝试无效对方效果的发动；若无效成功且对方效果的发动卡仍与效果关联，则将该卡破坏。
function c18967507.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断：无效发动是否成功，且被无效的效果的发动卡是否仍然存在并与效果关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动效果的卡片破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
