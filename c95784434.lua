--モルティング・エスケープ
-- 效果：
-- 爬虫类族怪兽才能装备。装备怪兽1回合只有1次不会被战斗破坏。这个效果适用的伤害步骤结束时，装备怪兽的攻击力上升300。
function c95784434.initial_effect(c)
	-- 爬虫类族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c95784434.target)
	e1:SetOperation(c95784434.operation)
	c:RegisterEffect(e1)
	-- 爬虫类族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c95784434.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽1回合只有1次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(c95784434.valcon)
	c:RegisterEffect(e3)
	-- 这个效果适用的伤害步骤结束时，装备怪兽的攻击力上升300。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(95784434,0))  --"攻击上升"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c95784434.adcon)
	e4:SetOperation(c95784434.adop)
	c:RegisterEffect(e4)
end
-- 定义装备限制函数，限制只能装备给爬虫类族怪兽
function c95784434.eqlimit(e,c)
	return c:IsRace(RACE_REPTILE)
end
-- 过滤场上表侧表示的爬虫类族怪兽
function c95784434.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- 装备魔法卡发动时的靶向选择与效果处理
function c95784434.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c95784434.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingTarget(c95784434.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的爬虫类族怪兽作为效果对象
	Duel.SelectTarget(tp,c95784434.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将此卡装备给目标怪兽
function c95784434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定是否为战斗破坏，若是则为装备卡注册一个在伤害步骤结束时重置的标记，并返回true以适用不被破坏效果
function c95784434.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(95784434,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
		return true
	else return false end
end
-- 检查装备卡是否在本次伤害步骤中适用了代替破坏的效果标记
function c95784434.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(95784434)~=0
end
-- 伤害步骤结束时的效果处理，使装备怪兽的攻击力上升300
function c95784434.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 装备怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:GetEquipTarget():RegisterEffect(e1)
end
