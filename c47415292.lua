--漆黒の闘龍
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「暗魔界的战士 暗黑之剑」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升400点。装备怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c47415292.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「暗魔界的战士 暗黑之剑」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47415292,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47415292.eqtg)
	e1:SetOperation(c47415292.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47415292,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为此卡正处于同盟装备状态，即作为装备卡时才能发动解除装备特殊召唤。
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c47415292.sptg)
	e2:SetOperation(c47415292.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升400点。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(400)
	-- 设置攻击力上升效果的条件为此卡正处于同盟装备状态，即作为装备卡时才适用。
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 装备怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_PIERCE)
	-- 设置贯穿伤害效果的条件为此卡正处于同盟装备状态，即作为装备卡时才适用。
	e5:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e5)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的条件为此卡正处于同盟装备状态，即作为装备卡时才适用。
	e6:SetCondition(aux.IsUnionState)
	e6:SetValue(c47415292.repval)
	c:RegisterEffect(e6)
	-- 给自己的「暗魔界的战士 暗黑之剑」装备
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UNION_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c47415292.eqlimit)
	c:RegisterEffect(e7)
end
c47415292.old_union=true
-- 定义代替破坏效果的判定函数：当破坏原因包含战斗破坏（REASON_BATTLE）时返回真，即只在战斗破坏时触发代替破坏。
function c47415292.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 定义同盟装备限制的判定函数：此卡只能装备给卡号 11321183 的「暗魔界的战士 暗黑之剑」。
function c47415292.eqlimit(e,c)
	return c:IsCode(11321183)
end
-- 筛选可装备对象：表侧表示的「暗魔界的战士 暗黑之剑」，且其当前没有装备任何同盟怪兽。
function c47415292.filter(c)
	return c:IsFaceup() and c:IsCode(11321183) and c:GetUnionCount()==0
end
-- 装备效果的发动时点处理：若为指定对象则验证对象合法性；否则判断是否满足发动条件，然后选择 1 只可装备的暗黑之剑作为对象。
function c47415292.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47415292.filter(chkc) end
	-- 发动条件判定：这张卡本回合尚未使用过装备/特殊召唤效果（标志 47415292 为 0），且自己魔陷区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(47415292)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在合法装备对象：自己怪兽区有 1 只表侧表示、未装备同盟的「暗魔界的战士 暗黑之剑」。
		and Duel.IsExistingTarget(c47415292.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择 1 张满足条件的「暗魔界的战士 暗黑之剑」作为装备对象，并登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c47415292.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：该效果将进行装备操作（CATEGORY_EQUIP），对象为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(47415292,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果处理：若此卡或目标卡不再与效果关联，或目标不再满足条件，则将此卡送去墓地；否则将此卡装备给目标怪兽，并标记为同盟装备状态。
function c47415292.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c47415292.filter(tc) then
		-- 当对象失效或不合法时，将这张同盟卡本身送去墓地（原因是效果），避免卡牌遗留在场上。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将这张卡作为装备卡装备给目标怪兽（保持原表示形式）；若装备失败则中止处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 给这张卡设置同盟装备状态，使攻守上升、贯穿、代替破坏等同盟效果开始生效。
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动时点处理：检测是否满足发动条件（本回合未使用过该效果、有怪兽区空位、此卡可特殊召唤）。
function c47415292.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：这张卡本回合尚未使用过装备/特殊召唤效果（标志 47415292 为 0），且自己怪兽区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(47415292)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：该效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），处理对象为此卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(47415292,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果处理：若此卡仍与效果关联，则以表侧攻击表示特殊召唤这张卡。
function c47415292.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧攻击表示特殊召唤到控制者场上（不检查召唤条件，但不解除苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
