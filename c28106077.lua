--ダグラの剣
-- 效果：
-- 只有天使族怪兽能装备这张卡。装备这张卡的怪兽攻击力上升500点。装备这张卡的怪兽对对方造成战斗伤害时，自己回复与伤害数值相同的基本分。
function c28106077.initial_effect(c)
	-- 只有天使族怪兽能装备这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c28106077.target)
	e1:SetOperation(c28106077.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽对对方造成战斗伤害时，自己回复与伤害数值相同的基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetDescription(aux.Stringid(28106077,0))  --"LP回复"
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c28106077.reccon)
	e2:SetTarget(c28106077.rectg)
	e2:SetOperation(c28106077.recop)
	c:RegisterEffect(e2)
	-- 只有天使族怪兽能装备这张卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c28106077.eqlimit)
	c:RegisterEffect(e3)
	-- 装备这张卡的怪兽攻击力上升500点。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 限制此卡只能装备给天使族怪兽：若目标怪兽不是天使族则不能装备。
function c28106077.eqlimit(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 筛选可作为装备对象的卡：必须是表侧表示且种族为天使族的怪兽。
function c28106077.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 装备效果发动时的取对象处理：选择自己或对方场上1只表侧表示的天使族怪兽作为装备对象，并设置将这张卡作为装备卡装备的信息。
function c28106077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c28106077.filter(chkc) end
	-- 发动时检查是否存在至少1只满足条件的表侧表示天使族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c28106077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择装备对象的选择提示（HINTMSG_EQUIP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上选择1只表侧表示的天使族怪兽作为装备对象，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c28106077.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁的效果分类为装备，对象卡为这张卡自身（用于后续处理）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与效果关联且对象仍表侧表示，则将这张卡装备给对象怪兽。
function c28106077.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁登记的对象怪兽（即装备目标）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽，完成装备动作。
		Duel.Equip(tp,c,tc)
	end
end
-- 回复触发条件：装备怪兽给对方造成战斗伤害时（装备怪兽在伤害事件中，且伤害由对方承受）。
function c28106077.reccon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec) and ep~=tp
end
-- 回复效果的发动时处理：将回复对象设为自己，回复量设为战斗伤害数值，并登记回复操作信息。
function c28106077.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这次连锁的对象玩家设为自己（表示回复LP的对象是自己）。
	Duel.SetTargetPlayer(tp)
	-- 将这次连锁的对象参数设为战斗伤害的数值，作为回复量。
	Duel.SetTargetParam(ev)
	-- 登记操作信息：本连锁将进行LP回复，对象为自己，数值为ev。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
-- 回复效果处理：从连锁信息中取出对象玩家和伤害数值，执行回复。
function c28106077.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出登记的对象玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点LP。
	Duel.Recover(p,d,REASON_EFFECT)
end
