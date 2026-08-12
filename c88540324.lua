--転生炎獣の烈爪
-- 效果：
-- 「转生炎兽」怪兽才能装备。
-- ①：「转生炎兽的烈爪」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽不会被战斗·效果破坏，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：装备怪兽是用和自身同名的怪兽为素材作连接召唤的自己的「转生炎兽」连接怪兽的场合，装备怪兽在同1次的战斗阶段中可以向怪兽作出最多有那个连接标记数量的攻击。
function c88540324.initial_effect(c)
	c:SetUniqueOnField(1,0,88540324)
	-- 「转生炎兽」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c88540324.target)
	e1:SetOperation(c88540324.operation)
	c:RegisterEffect(e1)
	-- 「转生炎兽」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c88540324.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽不会被战斗·效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- 向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
	-- 装备怪兽是用和自身同名的怪兽为素材作连接召唤的自己的「转生炎兽」连接怪兽的场合，装备怪兽在同1次的战斗阶段中可以向怪兽作出最多有那个连接标记数量的攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e6:SetValue(c88540324.atkval)
	c:RegisterEffect(e6)
	if not c88540324.global_check then
		c88540324.global_check=true
		-- 装备怪兽是用和自身同名的怪兽为素材作连接召唤的自己的「转生炎兽」连接怪兽的场合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c88540324.valcheck)
		-- 注册全局效果，用于检测怪兽进行连接召唤时是否使用了同名怪兽作为素材
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查连接召唤的素材中是否存在与该怪兽同名的怪兽，若存在则给该怪兽添加一个特定的Flag
function c88540324.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(88540324,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 装备限制：只能装备于「转生炎兽」怪兽
function c88540324.eqlimit(e,c)
	return c:IsSetCard(0x119)
end
-- 过滤条件：场上表侧表示的「转生炎兽」怪兽
function c88540324.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x119)
end
-- 装备魔法卡发动时的效果处理：选择场上1只表侧表示的「转生炎兽」怪兽为对象
function c88540324.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88540324.filter(chkc) end
	-- 检查场上是否存在可以装备的合法对象
	if chk==0 then return Duel.IsExistingTarget(c88540324.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择1只表侧表示的「转生炎兽」怪兽作为装备对象
	Duel.SelectTarget(tp,c88540324.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含装备操作，对象是这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理：将这张卡装备给选择的对象怪兽
function c88540324.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽可以向怪兽作出的最大追加攻击次数（连接标记数量减1）
function c88540324.atkval(e,c)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	local ct=0
	if tc:IsControler(e:GetHandlerPlayer()) and tc:IsSetCard(0x119) and tc:IsSummonType(SUMMON_TYPE_LINK) and tc:GetFlagEffect(88540324)~=0 then
		ct=tc:GetLink()
	end
	return math.max(0,ct-1)
end
