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
	-- 此效果的发动条件为装备怪兽处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c47415292.sptg)
	e2:SetOperation(c47415292.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升400点
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(400)
	-- 此效果的发动条件为装备怪兽处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 装备怪兽攻击守备表示的怪兽时，若攻击力超过那个守备力，给与对方那个数值的战斗伤害
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_PIERCE)
	-- 此效果的发动条件为装备怪兽处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e5)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 此效果的发动条件为装备怪兽处于同盟装备状态
	e6:SetCondition(aux.IsUnionState)
	e6:SetValue(c47415292.repval)
	c:RegisterEffect(e6)
	-- 1只怪兽可以装备的同盟最多1张
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UNION_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c47415292.eqlimit)
	c:RegisterEffect(e7)
end
c47415292.old_union=true
-- 当装备怪兽因战斗破坏时，此卡会代替破坏
function c47415292.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 只有「暗魔界的战士 暗黑之剑」可以作为此卡的装备对象
function c47415292.eqlimit(e,c)
	return c:IsCode(11321183)
end
-- 用于筛选可作为装备对象的「暗魔界的战士 暗黑之剑」
function c47415292.filter(c)
	return c:IsFaceup() and c:IsCode(11321183) and c:GetUnionCount()==0
end
-- 装备效果的处理函数，用于选择目标怪兽并设置操作信息
function c47415292.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47415292.filter(chkc) end
	-- 检查是否已发动过此效果（防止重复发动）
	if chk==0 then return e:GetHandler():GetFlagEffect(47415292)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否有满足条件的目标怪兽
		and Duel.IsExistingTarget(c47415292.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c47415292.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息，表示将进行装备处理
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(47415292,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数，用于完成装备过程
function c47415292.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c47415292.filter(tc) then
		-- 若装备失败则将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 特殊召唤效果的处理函数，用于判断是否可以发动并设置操作信息
function c47415292.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已发动过此效果（防止重复发动）
	if chk==0 then return e:GetHandler():GetFlagEffect(47415292)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息，表示将进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(47415292,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数，用于完成特殊召唤过程
function c47415292.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
