--バスターランチャー
-- 效果：
-- 这张卡只能装备在攻击力1000以下的怪兽上。伤害计算时，对方怪兽攻击表示则看攻击力，守备表示则看守备力，其数值在2500以上时，装备这张卡的怪兽攻击力上升2500。
function c84740193.initial_effect(c)
	-- 这张卡只能装备在攻击力1000以下的怪兽上。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c84740193.target)
	e1:SetOperation(c84740193.operation)
	c:RegisterEffect(e1)
	-- 伤害计算时，对方怪兽攻击表示则看攻击力，守备表示则看守备力，其数值在2500以上时，装备这张卡的怪兽攻击力上升2500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c84740193.atkcon)
	e2:SetValue(2500)
	c:RegisterEffect(e2)
	-- 这张卡只能装备在攻击力1000以下的怪兽上。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(c84740193.eqlimit)
	c:RegisterEffect(e3)
end
-- 定义装备限制函数，规定此卡只能装备在攻击力1000以下的怪兽上（伤害计算时除外）
function c84740193.eqlimit(e,c)
	-- 在伤害计算时（防止因攻击力上升导致装备卡自毁）或怪兽攻击力在1000以下时，允许装备
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL or c:IsAttackBelow(1000)
end
-- 过滤场上表侧表示且攻击力在1000以下的怪兽
function c84740193.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c84740193.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c84740193.filter(chkc) end
	-- 在发动时，检查场上是否存在符合装备条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c84740193.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c84740193.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理，执行装备操作
function c84740193.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断攻击力上升效果的条件：在伤害计算时，且对方怪兽的攻击力/守备力在2500以上
function c84740193.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec:IsRelateToBattle() then return end
	local bc=ec:GetBattleTarget()
	-- 判断当前是否为伤害计算时，且存在进行战斗的对方怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and bc
		and ((bc:IsAttackPos() and bc:IsAttackAbove(2500)) or (bc:IsDefensePos() and bc:IsDefenseAbove(2500)))
end
