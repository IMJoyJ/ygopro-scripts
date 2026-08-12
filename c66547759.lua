--No.23 冥界の霊騎士ランスロット
-- 效果：
-- 8星怪兽×2
-- ①：持有超量素材的这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- ③：1回合1次，这张卡以外的怪兽的效果·魔法·陷阱卡发动时，把这张卡1个超量素材取除发动。那个发动无效。
function c66547759.initial_effect(c)
	-- 添加超量召唤手续：8星怪兽×2。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c66547759.dacon)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66547759,0))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c66547759.descon)
	e2:SetTarget(c66547759.destg)
	e2:SetOperation(c66547759.desop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡以外的怪兽的效果·魔法·陷阱卡发动时，把这张卡1个超量素材取除发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66547759,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c66547759.discon)
	e3:SetCost(c66547759.discost)
	e3:SetTarget(c66547759.distg)
	e3:SetOperation(c66547759.disop)
	c:RegisterEffect(e3)
end
-- 设置该卡片的No.编号为23。
aux.xyz_number[66547759]=23
-- 直接攻击效果的发动条件：自身持有超量素材。
function c66547759.dacon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 破坏效果的发动条件：给与对方玩家战斗伤害。
function c66547759.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：场上表侧表示的怪兽。
function c66547759.filter(c)
	return c:IsFaceup()
end
-- 破坏效果的对象选择与发动准备。
function c66547759.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c66547759.filter(chkc) end
	-- 检查对方场上是否存在可作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c66547759.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c66547759.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作的连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理逻辑。
function c66547759.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽因效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 无效效果的发动条件：这张卡以外的怪兽的效果、魔法、陷阱卡发动时。
function c66547759.discon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		and re:GetHandler()~=e:GetHandler()
end
-- 无效效果的代价：取除这张卡的1个超量素材。
function c66547759.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 无效效果的发动准备。
function c66547759.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动操作的连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果的实际处理逻辑。
function c66547759.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前连锁是否为要无效的发动连锁。
	if Duel.GetCurrentChain()==ev+1 then
		-- 使该发动无效。
		Duel.NegateActivation(ev)
	end
end
