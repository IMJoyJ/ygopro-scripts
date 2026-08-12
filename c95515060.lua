--静寂のロッド－ケースト
-- 效果：
-- 装备这张卡的怪兽守备力上升500分。以装备怪兽为对象的这张卡以外的魔法卡的效果无效并破坏。
function c95515060.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c95515060.target)
	e1:SetOperation(c95515060.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽守备力上升500分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 以装备怪兽为对象的这张卡以外的魔法卡的效果无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c95515060.distg)
	c:RegisterEffect(e4)
	-- 以装备怪兽为对象的这张卡以外的魔法卡的效果无效并破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(c95515060.disop)
	c:RegisterEffect(e5)
	-- 以装备怪兽为对象的这张卡以外的魔法卡...破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_SELF_DESTROY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e6:SetTarget(c95515060.distg)
	c:RegisterEffect(e6)
end
-- 装备卡发动的对象选择与效果处理准备
function c95515060.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动时的效果处理，将自身装备给目标怪兽
function c95515060.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 筛选出以装备怪兽为对象的其他魔法卡
function c95515060.distg(e,c)
	local ec=e:GetHandler()
	if c==ec or c:GetCardTargetCount()==0 then return false end
	local eq=ec:GetEquipTarget()
	return eq and c:GetCardTarget():IsContains(eq) and c:IsType(TYPE_SPELL)
end
-- 在连锁处理时，无效并破坏以装备怪兽为对象的其他魔法卡的效果
function c95515060.disop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	if not ec:GetEquipTarget() or not re:IsActiveType(TYPE_SPELL) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前处理的连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(ec:GetEquipTarget()) then return end
	-- 如果成功无效该效果，且该魔法卡仍在场上
	if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该魔法卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
