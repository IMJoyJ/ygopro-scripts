--No.39 希望皇ホープ
-- 效果：
-- 4星怪兽×2
-- ①：自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。
-- ②：这张卡没有超量素材的状态被选择作为攻击对象的场合发动。这张卡破坏。
function c84013237.initial_effect(c)
	-- 为卡片添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84013237,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCost(c84013237.atkcost)
	e1:SetOperation(c84013237.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡没有超量素材的状态被选择作为攻击对象的场合发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84013237,1))  --"自坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(c84013237.descon)
	e2:SetTarget(c84013237.destg)
	e2:SetOperation(c84013237.desop)
	c:RegisterEffect(e2)
end
-- 设置该卡片的“No.”数值为39
aux.xyz_number[84013237]=39
-- 攻击无效效果的发动代价：检查并取除这张卡的1个超量素材
function c84013237.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 攻击无效效果的处理：无效那次攻击
function c84013237.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
-- 破坏效果的发动条件：自身被选择为攻击对象且没有超量素材
function c84013237.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前攻击对象是否为自身，且自身的超量素材数量是否为0
	return Duel.GetAttackTarget()==c and c:GetOverlayCount()==0
end
-- 破坏效果的目标处理：设置破坏自身的操作信息
function c84013237.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：破坏1张自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的处理：若自身仍在场，则将自身破坏
function c84013237.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
