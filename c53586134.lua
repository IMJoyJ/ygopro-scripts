--バブル・ショット
-- 效果：
-- 「元素英雄 水泡侠」才能装备。装备怪兽的攻击力上升800。装备怪兽被战斗破坏的场合，这张卡代替破坏，装备怪兽的控制者的战斗伤害为0。
function c53586134.initial_effect(c)
	-- 将这张卡注册到「元素英雄」系列字段（0x3008）的名单中，使其在相关系列判定中被视为「元素英雄」卡。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 水泡侠」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c53586134.target)
	e1:SetOperation(c53586134.operation)
	c:RegisterEffect(e1)
	-- 「元素英雄 水泡侠」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c53586134.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，这张卡代替破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e4:SetValue(c53586134.repval)
	c:RegisterEffect(e4)
	-- 装备怪兽的控制者的战斗伤害为0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 装备限制判定：只有卡号为79979666的「元素英雄 水泡侠」才能装备这张卡。
function c53586134.eqlimit(e,c)
	return c:IsCode(79979666)
end
-- 选择装备对象的过滤条件：必须为表侧表示且卡号为79979666的「元素英雄 水泡侠」。
function c53586134.filter(c)
	return c:IsFaceup() and c:IsCode(79979666)
end
-- 装备魔法的发动与取对象处理：选择场上表侧表示的「元素英雄 水泡侠」作为这张卡的装备对象。
function c53586134.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53586134.filter(chkc) end
	-- 发动条件检查：双方场上存在至少1张表侧表示且符合条件的「元素英雄 水泡侠」可供选择。
	if chk==0 then return Duel.IsExistingTarget(c53586134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给出选择提示，让玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1张符合条件的「元素英雄 水泡侠」，并将其登记为这张卡效果的对象。
	Duel.SelectTarget(tp,c53586134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡自身作为要进行装备的对象，以便后续装备处理及相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：若这张卡和目标卡都仍然与本次效果相关且目标表侧表示，则将这张卡装备给目标怪兽。
function c53586134.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 代替破坏的触发判定：当原破坏原因包含战斗破坏时返回true，即仅在战斗破坏时才用这张卡代替装备怪兽被破坏。
function c53586134.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
