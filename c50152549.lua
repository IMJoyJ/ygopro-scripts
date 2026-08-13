--しびれ薬
-- 效果：
-- 机械族以外的怪兽装备可能。装备怪兽不能攻击宣言。
function c50152549.initial_effect(c)
	-- 机械族以外的怪兽装备可能。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c50152549.target)
	e1:SetOperation(c50152549.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- 机械族以外的怪兽装备可能。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c50152549.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定：仅当目标怪兽不是机械族时返回 true，即这张卡只能装备给机械族以外的怪兽。
function c50152549.eqlimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 过滤条件：目标怪兽必须表侧表示且种族不是机械族。
function c50152549.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
-- 目标设定函数：发动时确认场上存在表侧表示且非机械族的怪兽；让玩家选择 1 只作为装备对象；并登记本连锁将进行装备的信息。
function c50152549.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50152549.filter(chkc) end
	-- 发动条件检查：当 chk==0 时，判断场上是否存在至少 1 只满足 filter 的怪兽（表侧表示且非机械族）。
	if chk==0 then return Duel.IsExistingTarget(c50152549.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：向玩家展示“请选择要装备的卡”的选择窗口。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从双方怪兽区域选择 1 只符合条件的表侧表示非机械族怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c50152549.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：将类别设为 CATEGORY_EQUIP，对象为这张卡，表示接下来处理时会把这张卡装备给目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取出目标怪兽；若这张卡和目标怪兽仍与本次效果关联，且目标怪兽仍表侧表示，则将这张卡装备给目标怪兽。
function c50152549.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁的第一个（也是唯一一个）目标怪兽，即被选为装备对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备：由发动者 tp 将这张卡作为装备魔法卡装备到目标怪兽的装备区。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
