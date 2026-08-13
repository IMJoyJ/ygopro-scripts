--魔菌
-- 效果：
-- 植物族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c39774685.initial_effect(c)
	-- 植物族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c39774685.target)
	e1:SetOperation(c39774685.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力·守备力上升300。（攻击力部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的攻击力·守备力上升300。（守备力部分）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 植物族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c39774685.eqlimit)
	c:RegisterEffect(e4)
end
-- 判定装备对象是否为植物族，用于实现“植物族才能装备”的装备限制。
function c39774685.eqlimit(e,c)
	return c:IsRace(RACE_PLANT)
end
-- 筛选场上表侧表示且种族为植物族的怪兽，作为可装备对象。
function c39774685.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 装备魔法发动时的目标处理：确认对象合法性，选择1只表侧表示植物族怪兽作为装备对象，并设置装备操作信息。
function c39774685.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39774685.filter(chkc) end
	-- 检查场上是否存在至少1只表侧表示植物族怪兽可作为这张装备魔法的对象；若存在，效果满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(c39774685.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方主要怪兽区选择1只表侧表示植物族怪兽作为装备对象，并将其登记为这张效果的取对象目标。
	Duel.SelectTarget(tp,c39774685.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：宣告将处理装备效果，目标为这张魔菌自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法发动时的处理：若此卡和目标怪兽仍与效果相关且目标表侧表示，则将此卡装备给目标怪兽。
function c39774685.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将魔菌作为装备卡装备到目标怪兽的装备区。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
