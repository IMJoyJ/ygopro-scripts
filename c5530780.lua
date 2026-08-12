--エクソシスター・ジブリーヌ
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
-- ③：把这张卡1个超量素材取除才能发动。这个回合中，自己场上的超量怪兽的攻击力上升800。
function c5530780.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×2。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(c5530780.effcon)
	e1:SetOperation(c5530780.regop)
	c:RegisterEffect(e1)
	-- 用「救祓少女」怪兽为素材作超量召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c5530780.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ①：这张卡用「救祓少女」怪兽为素材作超量召唤的自己·对方回合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5530780,0))  --"对方怪兽效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,5530780)
	e3:SetCondition(c5530780.discon)
	e3:SetTarget(c5530780.distg)
	e3:SetOperation(c5530780.disop)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡不会被从墓地特殊召唤的怪兽发动的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(c5530780.indval)
	c:RegisterEffect(e4)
	-- ③：把这张卡1个超量素材取除才能发动。这个回合中，自己场上的超量怪兽的攻击力上升800。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(5530780,1))  --"攻击力上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,5530781)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(c5530780.atkcost)
	e5:SetOperation(c5530780.atkop)
	c:RegisterEffect(e5)
end
-- 判定这张卡是否是以「救祓少女」怪兽为素材进行的超量召唤。
function c5530780.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 给自身注册一个在回合结束时重置的Flag，用于标记本回合已满足①效果的发动条件。
function c5530780.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(5530780,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查超量素材中是否存在「救祓少女」怪兽，并将检查结果（1或0）作为Label传递给e1。
function c5530780.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x172) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定自身是否存在对应的Flag，即本回合是否是用「救祓少女」怪兽为素材超量召唤成功。
function c5530780.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(5530780)~=0
end
-- 效果①的靶向/目标选择函数，选择对方场上1只未被无效的效果怪兽作为对象。
function c5530780.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定当前指向的对象是否为对方场上符合无效化条件的效果怪兽。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判定对方场上是否存在至少1只符合无效化条件的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效化效果的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只符合无效化条件的效果怪兽作为效果对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的执行函数，使作为对象的那只对方怪兽的效果直到回合结束时无效。
function c5530780.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判定破坏效果是否由从墓地特殊召唤的怪兽发动。
function c5530780.indval(e,te,rp)
	return te:IsActivated() and te:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 效果③的发动代价：把这张卡1个超量素材取除。
function c5530780.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的执行函数，使自己场上所有的超量怪兽攻击力上升800，直到回合结束。
function c5530780.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的超量怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤并锁定攻击力上升效果的作用对象为超量怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e1:SetValue(800)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力上升的场地/玩家效果注册到全局环境中。
	Duel.RegisterEffect(e1,tp)
end
