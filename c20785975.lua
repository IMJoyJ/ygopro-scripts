--CNo.103 神葬零嬢ラグナ・インフィニティ
-- 效果：
-- 5星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，那只怪兽除外。这个效果在对方回合也能发动。
-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。这个效果在自己墓地有「No.103 神葬零娘 暮零」存在的场合才能发动和处理。
function c20785975.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5、数量为3的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，那只怪兽除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20785975,0))  --"除外伤害"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c20785975.cost)
	e1:SetTarget(c20785975.target)
	e1:SetOperation(c20785975.operation)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡被破坏送去墓地时才能发动。这张卡特殊召唤。这个效果在自己墓地有「No.103 神葬零娘 暮零」存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20785975,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c20785975.spcon)
	e2:SetTarget(c20785975.sptg)
	e2:SetOperation(c20785975.spop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为103
aux.xyz_number[20785975]=103
-- 支付1个超量素材作为cost
function c20785975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的怪兽：正面表示、攻击力与原本攻击力不同、可以除外
function c20785975.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack()) and c:IsAbleToRemove()
end
-- 选择满足条件的对方怪兽作为对象，计算攻击力差值并设置操作信息
function c20785975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c20785975.filter(chkc) end
	-- 检查是否存在满足条件的对方怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c20785975.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的对方怪兽作为对象
	local g=Duel.SelectTarget(tp,c20785975.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	-- 设置操作信息：除外对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,atk)
end
-- 处理效果：对对象怪兽造成伤害并除外
function c20785975.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	-- 判断对象怪兽是否仍然在场且处于正面表示状态，并造成伤害
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		-- 将对象怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件：被破坏、在怪兽区、有超量素材、墓地有「No.103 神葬零娘 暮零」
function c20785975.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
		-- 检查墓地是否存在「No.103 神葬零娘 暮零」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,94380860)
end
-- 设置特殊召唤的处理信息
function c20785975.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果：特殊召唤自身
function c20785975.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查墓地是否存在「No.103 神葬零娘 暮零」
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,94380860) then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
