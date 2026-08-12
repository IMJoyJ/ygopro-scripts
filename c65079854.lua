--憎悪の棘
-- 效果：
-- 「黑蔷薇龙」或者植物族怪兽才能装备。装备怪兽的攻击力上升600。装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。装备怪兽向怪兽攻击的场合，伤害计算后攻击对象怪兽的攻击力·守备力下降600。和装备怪兽进行战斗的对方怪兽不会被那次战斗破坏。
function c65079854.initial_effect(c)
	-- 在卡片中注册记载了「黑蔷薇龙」的卡片密码，用于相关卡片的检索或关联判定。
	aux.AddCodeList(c,73580471)
	-- 「黑蔷薇龙」或者植物族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c65079854.target)
	e1:SetOperation(c65079854.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(600)
	c:RegisterEffect(e2)
	-- 装备怪兽攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 「黑蔷薇龙」或者植物族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c65079854.eqlimit)
	c:RegisterEffect(e4)
	-- 和装备怪兽进行战斗的对方怪兽不会被那次战斗破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(c65079854.indestg)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- 装备怪兽向怪兽攻击的场合，伤害计算后攻击对象怪兽的攻击力·守备力下降600。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(65079854,0))  --"攻击下降"
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_BATTLED)
	e6:SetCondition(c65079854.adcon)
	e6:SetOperation(c65079854.adop)
	c:RegisterEffect(e6)
end
-- 定义装备限制：只能装备给「黑蔷薇龙」或者植物族怪兽。
function c65079854.eqlimit(e,c)
	return c:IsCode(73580471) or c:IsRace(RACE_PLANT)
end
-- 过滤函数：用于筛选场上表侧表示的「黑蔷薇龙」或植物族怪兽。
function c65079854.filter(c)
	return c:IsFaceup() and (c:IsCode(73580471) or c:IsRace(RACE_PLANT))
end
-- 装备魔法卡发动时的效果目标选择与处理函数。
function c65079854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c65079854.filter(chkc) end
	-- 在发动时，检查场上是否存在可以装备的合法怪兽。
	if chk==0 then return Duel.IsExistingTarget(c65079854.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 在界面上提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只符合条件的怪兽作为装备对象。
	Duel.SelectTarget(tp,c65079854.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含装备操作，操作对象为自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理函数，执行实际的装备操作。
function c65079854.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 确定不会被战斗破坏的目标为与装备怪兽进行战斗的对方怪兽。
function c65079854.indestg(e,c)
	return c==e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 判定是否满足伤害计算后攻击对象攻防下降的触发条件。
function c65079854.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击者是否为装备怪兽，且存在被攻击的怪兽。
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget() and Duel.GetAttackTarget()~=nil
end
-- 执行攻防下降的效果处理，使攻击对象的攻击力和守备力下降600。
function c65079854.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备怪兽攻击的对方怪兽（攻击对象）。
	local bc=Duel.GetAttackTarget()
	-- 装备怪兽向怪兽攻击的场合，伤害计算后攻击对象怪兽的攻击力·守备力下降600。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-600)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	bc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	bc:RegisterEffect(e2)
end
