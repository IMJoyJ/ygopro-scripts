--RR－ファイナル・フォートレス・ファルコン
-- 效果：
-- 12星怪兽×3
-- ①：有「急袭猛禽」超量怪兽在作为超量素材中的这张卡不受其他卡的效果影响。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。除外的自己的「急袭猛禽」怪兽全部回到墓地。
-- ③：这张卡的攻击破坏怪兽时，把自己墓地1只「急袭猛禽」超量怪兽除外才能发动。这张卡可以继续攻击。这个效果1回合可以使用最多2次。
function c43047672.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为12、数量为3的怪兽进行XYZ召唤
	aux.AddXyzProcedure(c,nil,12,3)
	c:EnableReviveLimit()
	-- ①：有「急袭猛禽」超量怪兽在作为超量素材中的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43047672.imcon)
	e1:SetValue(c43047672.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。除外的自己的「急袭猛禽」怪兽全部回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43047672,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43047672.cost)
	e2:SetTarget(c43047672.target)
	e2:SetOperation(c43047672.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击破坏怪兽时，把自己墓地1只「急袭猛禽」超量怪兽除外才能发动。这张卡可以继续攻击。这个效果1回合可以使用最多2次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43047672,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(2)
	e3:SetCondition(c43047672.atcon)
	e3:SetCost(c43047672.atcost)
	e3:SetOperation(c43047672.atop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否为「急袭猛禽」超量怪兽
function c43047672.imfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
-- 条件函数，判断是否有「急袭猛禽」超量怪兽作为超量素材
function c43047672.imcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(c43047672.imfilter,1,nil)
end
-- 效果过滤函数，使该卡不受对方效果影响
function c43047672.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 效果发动时的费用支付，将1个超量素材除外
function c43047672.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于判断除外区的怪兽是否为「急袭猛禽」怪兽且为怪兽卡
function c43047672.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER)
end
-- 设置效果发动时的操作信息，确定将要送去墓地的卡
function c43047672.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即除外区是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43047672.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 获取满足条件的除外区怪兽组
	local g=Duel.GetMatchingGroup(c43047672.filter,tp,LOCATION_REMOVED,0,nil)
	-- 设置连锁操作信息，指定将要处理的卡为除外区的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果发动时的操作，将符合条件的除外区怪兽送去墓地
function c43047672.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的除外区怪兽组
	local g=Duel.GetMatchingGroup(c43047672.filter,tp,LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽以效果和回到墓地的原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
-- 触发效果的条件函数，判断是否为攻击怪兽并满足连锁攻击条件
function c43047672.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为攻击怪兽并满足连锁攻击条件
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable(0)
end
-- 过滤函数，用于判断墓地的怪兽是否为「急袭猛禽」超量怪兽且可作为费用
function c43047672.atfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用支付，选择1只墓地的「急袭猛禽」超量怪兽除外
function c43047672.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地是否存在至少1张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43047672.atfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只怪兽除外
	local g=Duel.SelectMatchingCard(tp,c43047672.atfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽以正面表示的形式除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的操作，使攻击卡可以再进行1次攻击
function c43047672.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
end
