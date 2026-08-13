--ヘル・アライアンス
-- 效果：
-- 场上每有1只表侧表示存在的和装备怪兽同名的怪兽，装备怪兽攻击力上升800。
function c46910446.initial_effect(c)
	-- 中的“装备怪兽”部分：作为装备魔法发动时，选择场上1只表侧表示怪兽作为装备对象，并通过处理将其装备给该怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46910446.target)
	e1:SetOperation(c46910446.operation)
	c:RegisterEffect(e1)
	-- 对应效果原文“装备怪兽攻击力上升800”：注册装备状态下提升攻击力的效果，并通过value函数根据场上同名表侧怪兽数量计算上升值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c46910446.value)
	c:RegisterEffect(e2)
	-- 对应效果原文中“装备怪兽”的含义：设置本卡作为装备卡时的装备对象限制（此处允许装备给怪兽），且该限制不可被无效。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 发动时的对象选择处理：确认场上存在表侧表示怪兽可作装备对象后，提示玩家选择1只表侧表示怪兽，并设为这张装备卡的目标，同时登记装备操作信息。
function c46910446.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：效果发动时检查场上是否存在至少1只表侧表示怪兽可作为装备对象，没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示信息，提示文字为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上选择1只表侧表示怪兽作为这张装备卡的目标，并自动将所选卡与当前连锁建立对象关联。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：告知系统本连锁执行的是装备动作，处理的卡为本张卡，数量为1，为后续时点检测提供信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的装备执行：检查本张装备卡与目标怪兽仍与效果关联且目标表侧表示后，将这张卡作为装备卡装备给目标怪兽。
function c46910446.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标怪兽（取自当前连锁记录的对象）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给目标怪兽，装备成功后才进入装备状态，后续攻击力效果开始适用。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤函数：判断场上某只怪兽是否表侧表示，且卡名与传入的code（装备怪兽当前卡名）一致，用于统计同名怪兽数量。
function c46910446.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 计算攻击力增加值的函数：统计全场所有表侧表示且与装备怪兽同名的怪兽数量，乘以800作为攻击力上升数值。
function c46910446.value(e,c)
	-- 返回攻击力上升的具体数值：符合条件的同名表侧怪兽数 × 800。
	return Duel.GetMatchingGroupCount(c46910446.filter,0,LOCATION_MZONE,LOCATION_MZONE,c,c:GetCode())*800
end
