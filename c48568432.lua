--トライゴン
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从自己墓地选择1只机械族·光属性·4星以下的怪兽特殊召唤。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c48568432.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48568432,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c48568432.eqtg)
	e1:SetOperation(c48568432.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48568432,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置e2的发动条件：三角火龙必须处于同盟装备状态（即作为装备卡装备在怪兽身上）时才能发动解除装备并特召的效果。
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c48568432.sptg)
	e2:SetOperation(c48568432.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的发动条件：此效果仅在三角火龙作为装备卡装备中才适用，即装备怪兽被破坏时才能由三角火龙代替破坏。
	e3:SetCondition(aux.IsUnionState)
	-- 设置代替破坏效果的判定值：使用aux.UnionReplaceFilter判断装备怪兽因战斗或效果被破坏时，三角火龙是否可以作为代替破坏的对象。
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 可以当作装备卡使用给自己场上的机械族怪兽装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c48568432.eqlimit)
	c:RegisterEffect(e4)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从自己墓地选择1只机械族·光属性·4星以下的怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(48568432,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c48568432.spcon2)
	e5:SetTarget(c48568432.sptg2)
	e5:SetOperation(c48568432.spop2)
	c:RegisterEffect(e5)
end
c48568432.old_union=true
-- 定义同盟装备限制的判定：三角火龙作为装备卡时，只能装备给机械族怪兽。
function c48568432.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义装备对象过滤条件：对象必须是表侧表示、机械族、且当前没有装备其他同盟怪兽（保证1只怪兽最多装备1张同盟）。
function c48568432.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetUnionCount()==0
end
-- 装备效果的目标处理：检查发动条件（本回合未使用过效果、魔陷区有空位、存在可装备对象），并选择1只符合条件的机械族怪兽作为装备对象。
function c48568432.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48568432.filter(chkc) end
	-- 发动条件检查：三角火龙本回合尚未使用过‘一回合一次’的装备/解除效果，且自己魔陷区有空位可以放置装备卡。
	if chk==0 then return e:GetHandler():GetFlagEffect(48568432)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：场上存在至少1只表侧表示且符合条件的机械族怪兽可以作为装备对象（取对象效果需要先确认目标存在）。
		and Duel.IsExistingTarget(c48568432.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示“请选择要装备的卡”，用于选择要装备的机械族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只符合条件的机械族怪兽，并设立为这张卡发动时的效果对象。
	local g=Duel.SelectTarget(tp,c48568432.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 向系统登记本次操作信息：将进行装备分类（CATEGORY_EQUIP）的处理，目标为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(48568432,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的处理：若三角火龙和目标怪兽都仍合法，则将三角火龙装备给目标怪兽，并设置为同盟装备状态；若目标不合法，则三角火龙送去墓地。
function c48568432.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次装备效果选择的目标怪兽（要装备的机械族怪兽）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c48568432.filter(tc) then
		-- 装备目标不合法时，将三角火龙以效果原因送去墓地（装备失败处理）。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将三角火龙作为装备卡装备给目标怪兽（保持其当前表示形式），若装备失败则直接结束处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为三角火龙设置同盟装备状态，使其后续被视为同盟装备卡，并影响其他效果的发动条件。
	aux.SetUnionState(c)
end
-- 解除装备特召效果的发动条件检查：本回合未使用过该效果、主要怪兽区有空位、三角火龙自身可以特殊召唤；满足后登记特殊召唤信息。
function c48568432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：三角火龙本回合尚未使用过‘一回合一次’的装备/解除效果，且自己主要怪兽区有空位可特殊召唤。
	if chk==0 then return e:GetHandler():GetFlagEffect(48568432)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 向系统登记本次操作信息：本次处理将特殊召唤三角火龙自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(48568432,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 解除装备特召的实际处理：若三角火龙仍与效果关联，则将其特殊召唤。
function c48568432.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将三角火龙以表侧攻击表示特殊召唤到自己场上，不检查召唤条件，但保留苏生限制检查。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 诱发效果的发动条件：三角火龙处于同盟装备状态，且装备怪兽战斗破坏对方怪兽。
function c48568432.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前三角火龙确实是装备状态，并且战斗破坏对方怪兽的怪兽正是它所装备的怪兽。
	return aux.IsUnionState(e) and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 定义墓地特召对象的过滤条件：机械族、光属性、4星以下，并且可以被效果特殊召唤。
function c48568432.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 诱发效果的目标处理：效果必发，从自己墓地选择1只符合条件的机械族·光属性·4星以下怪兽作为特殊召唤对象。
function c48568432.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48568432.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家显示选择提示“请选择要特殊召唤的卡”，用于选择墓地特召对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽，并将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c48568432.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本次操作信息：本次处理将进行特殊召唤，对象为已选择的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 诱发特召的实际处理：若选择的对象仍与效果关联，则将其特殊召唤。
function c48568432.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次诱发效果选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选择的墓地怪兽以表侧表示特殊召唤到自己场上，检查召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
