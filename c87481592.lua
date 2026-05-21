--教導神理
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力在装备怪兽是「教导」怪兽的场合攻击力上升自身的等级×100，那以外的场合下降自己场上的「教导」怪兽数量×200。
-- ②：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。从额外卡组把1只怪兽送去墓地。
function c87481592.initial_effect(c)
	-- ①：装备怪兽的攻击力在装备怪兽是「教导」怪兽的场合攻击力上升自身的等级×100，那以外的场合下降自己场上的「教导」怪兽数量×200。（卡片的发动与装备处理）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c87481592.target)
	e1:SetOperation(c87481592.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力在装备怪兽是「教导」怪兽的场合攻击力上升自身的等级×100，那以外的场合下降自己场上的「教导」怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c87481592.atkval)
	c:RegisterEffect(e2)
	-- ②：装备怪兽被破坏让这张卡被送去墓地的场合才能发动。从额外卡组把1只怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(87481592,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,87481592)
	e4:SetCondition(c87481592.tgcon)
	e4:SetTarget(c87481592.tgtg)
	e4:SetOperation(c87481592.tgop)
	c:RegisterEffect(e4)
	-- 装备魔法卡的装备限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 装备魔法卡发动时的对象选择与效果处理准备
function c87481592.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的操作为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理，将这张卡装备给目标怪兽
function c87481592.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤自己场上表侧表示的「教导」怪兽
function c87481592.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- 计算装备怪兽的攻击力增减值
function c87481592.atkval(e,c)
	if c:IsSetCard(0x145) then
		return c:GetLevel()*100
	else
		-- 非「教导」怪兽的场合，攻击力下降自己场上的「教导」怪兽数量×200
		return Duel.GetMatchingGroupCount(c87481592.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-200
	end
end
-- 检查发动条件：装备怪兽被破坏导致这张卡被送去墓地
function c87481592.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY)
end
-- 效果②的发动准备，检查额外卡组是否有卡可以送去墓地并设置连锁信息
function c87481592.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁信息，表示该效果的操作为从额外卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：从额外卡组选择1只怪兽送去墓地
function c87481592.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
