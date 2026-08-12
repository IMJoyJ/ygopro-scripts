--パワー・ピカクス
-- 效果：
-- 1回合1次，可以选择持有装备怪兽的等级以下的等级的对方墓地存在的1只怪兽从游戏中除外，直到结束阶段时装备怪兽的攻击力上升500。
function c90246973.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c90246973.target)
	e1:SetOperation(c90246973.operation)
	c:RegisterEffect(e1)
	-- （装备限制）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择持有装备怪兽的等级以下的等级的对方墓地存在的1只怪兽从游戏中除外，直到结束阶段时装备怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90246973,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c90246973.rmtg)
	e3:SetOperation(c90246973.rmop)
	c:RegisterEffect(e3)
end
-- 装备魔法卡发动时的对象选择与效果处理
function c90246973.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理，将自身装备给目标怪兽
function c90246973.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤对方墓地中等级在装备怪兽等级以下且可以除外的怪兽
function c90246973.rmfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsAbleToRemove()
end
-- 除外并加攻效果的对象选择与发动准备
function c90246973.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c90246973.rmfilter(chkc,ec:GetLevel()) end
	-- 检查对方墓地是否存在等级在装备怪兽等级以下且可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c90246973.rmfilter,tp,0,LOCATION_GRAVE,1,nil,ec:GetLevel()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1只满足等级条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c90246973.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil,ec:GetLevel())
	-- 设置连锁信息，表示该效果包含除外操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 除外并加攻效果的处理，将目标怪兽除外并提升装备怪兽的攻击力
function c90246973.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 获取要除外的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍存在于墓地，则将其表侧表示除外，若除外成功则执行后续处理
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 直到结束阶段时装备怪兽的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		ec:RegisterEffect(e1)
	end
end
