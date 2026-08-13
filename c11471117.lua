--ライトイレイザー
-- 效果：
-- 光属性·战士族才能装备。和装备怪兽进行战斗的怪兽在那个伤害步骤结束时从游戏中除外。
function c11471117.initial_effect(c)
	-- 光属性·战士族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c11471117.target)
	e1:SetOperation(c11471117.operation)
	c:RegisterEffect(e1)
	-- 光属性·战士族才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c11471117.eqlimit)
	c:RegisterEffect(e2)
	-- 和装备怪兽进行战斗的怪兽在那个伤害步骤结束时从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11471117,0))  --"战斗对象除外"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c11471117.rmcon)
	e3:SetTarget(c11471117.rmtg)
	e3:SetOperation(c11471117.rmop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：仅允许光属性·战士族怪兽装备此卡。
function c11471117.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
end
-- 选择装备对象时的过滤条件：怪兽需表侧表示，且为光属性·战士族。
function c11471117.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
end
-- 发动的目标处理流程：先检查指定对象是否合法，再判断场上是否存在合法装备对象；若存在，则提示玩家选择1只光属性·战士族表侧表示怪兽作为装备对象，并设置装备效果的操作信息。
function c11471117.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11471117.filter(chkc) end
	-- 发动合法性检查：确认玩家或对方场上存在1只满足条件（表侧表示·光属性·战士族）且可被选为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c11471117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示框，让玩家从符合条件的怪兽中选择要装备的卡（提示文字为“请选择要装备的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只满足条件的怪兽作为效果对象，并将其登记为当前连锁的对象（取对象）。
	Duel.SelectTarget(tp,c11471117.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将处理装备，装备对象为本卡（光之抹杀剑），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备操作：若本卡仍与效果相关、目标怪兽仍与效果相关且仍为表侧表示，则将此卡装备给目标怪兽。
function c11471117.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象中第一张卡（即选择的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将光之抹杀剑作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 除外效果的发动条件：伤害计算后，若装备怪兽参与了战斗（无论是作为攻击方还是被攻击方），则满足条件。
function c11471117.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击方怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击方怪兽（可能为nil，例如直接攻击时）。
	local d=Duel.GetAttackTarget()
	local c=e:GetHandler():GetEquipTarget()
	return d and (a==c or d==c)
end
-- 除外效果的发动时点判定：这是必发效果，无额外条件，直接允许发动。
function c11471117.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果处理：取得与装备怪兽战斗的对方怪兽，并创建延迟效果，在伤害步骤结束时将其除外。
function c11471117.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	-- 从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e1:SetLabelObject(tc)
	e1:SetOperation(c11471117.rmop2)
	-- 将延迟除外效果注册到场上（以当前玩家tp为控制者），使其在伤害步骤结束时生效。
	Duel.RegisterEffect(e1,tp)
end
-- 延迟效果处理：取出之前记录的战斗对象怪兽，并将其除外。
function c11471117.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以表侧表示形式将目标怪兽从游戏中除外（原因：效果）。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
