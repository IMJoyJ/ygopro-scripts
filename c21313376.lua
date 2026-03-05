--No.14 強欲のサラメーヤ
-- 效果：
-- 5星怪兽×2
-- ①：只要这张卡在怪兽区域存在，对方的效果发生的对自己的效果伤害由对方代受。
-- ②：这张卡战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。持有破坏的那只怪兽的原本攻击力以下的攻击力的场上的怪兽全部破坏。
function c21313376.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽2只进行叠放
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，对方的效果发生的对自己的效果伤害由对方代受
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c21313376.refcon)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。持有破坏的那只怪兽的原本攻击力以下的攻击力的场上的怪兽全部破坏
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e2:SetCondition(aux.bdogcon)
	e2:SetCost(c21313376.descost)
	e2:SetTarget(c21313376.destg)
	e2:SetOperation(c21313376.desop)
	c:RegisterEffect(e2)
end
-- 设置该卡为No.14编号怪兽
aux.xyz_number[21313376]=14
-- 反射伤害效果的判断函数，判断是否为效果伤害且伤害来源为对方
function c21313376.refcon(e,re,val,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 支付效果代价，从自身去除1个超量素材
function c21313376.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，筛选场上攻击力不超过指定值的表侧表示怪兽
function c21313376.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 设置效果发动时的处理目标，检索满足条件的怪兽组并设置破坏操作信息
function c21313376.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetBattleTarget():GetBaseAttack()
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置连锁操作信息，确定要处理的破坏对象数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，对满足条件的怪兽进行破坏
function c21313376.desop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetHandler():GetBattleTarget():GetBaseAttack()
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 将指定怪兽组以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
