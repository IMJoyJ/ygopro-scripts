--No.14 強欲のサラメーヤ
-- 效果：
-- 5星怪兽×2
-- ①：只要这张卡在怪兽区域存在，对方的效果发生的对自己的效果伤害由对方代受。
-- ②：这张卡战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。持有破坏的那只怪兽的原本攻击力以下的攻击力的场上的怪兽全部破坏。
function c21313376.initial_effect(c)
	-- 给这张卡添加XYZ召唤手续：把2只等级5的怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，对方的效果发生的对自己的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c21313376.refcon)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。持有破坏的那只怪兽的原本攻击力以下的攻击力的场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件：这张卡与对方怪兽战斗并将其战斗破坏送去墓地时才能发动。
	e2:SetCondition(aux.bdogcon)
	e2:SetCost(c21313376.descost)
	e2:SetTarget(c21313376.destg)
	e2:SetOperation(c21313376.desop)
	c:RegisterEffect(e2)
end
-- 将这张卡的卡号登记为No.14，用于No.系列相关规则判断。
aux.xyz_number[21313376]=14
-- EFFECT_REFLECT_DAMAGE的判定函数：当伤害原因是效果伤害、且造成伤害的玩家是这张卡控制者的对方时，把对自己造成的效果伤害反射给对方代受。
function c21313376.refcon(e,re,val,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetHandlerPlayer()
end
-- 取除1个超量素材作为发动代价：先检查能否取除，若能则实际取除1个超量素材。
function c21313376.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选场上表侧表示且攻击力不高于给定攻击力atk的怪兽，用于决定被破坏的对象。
function c21313376.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 发动目标的判定与操作信息设置：取得被战斗破坏的对方怪兽的原本攻击力，若场上存在满足条件的怪兽则可发动；将场上全部满足条件的怪兽作为本次破坏的对象信息。
function c21313376.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=e:GetHandler():GetBattleTarget():GetBaseAttack()
	-- 发动检查：场上是否存在至少1只表侧表示且攻击力不高于被破坏怪兽原本攻击力的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 取出当前场上所有满足条件的怪兽组，用于设置操作信息。
	local g=Duel.GetMatchingGroup(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置本次连锁的破坏操作信息：要破坏的对象是g中的全部怪兽，数量为g的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：重新取得被战斗破坏怪兽的原本攻击力，获取场上全部满足条件的怪兽组，并将它们全部破坏。
function c21313376.desop(e,tp,eg,ep,ev,re,r,rp)
	local atk=e:GetHandler():GetBattleTarget():GetBaseAttack()
	-- 效果处理时再次获取当前场上所有满足条件的怪兽组，确定实际破坏的对象。
	local g=Duel.GetMatchingGroup(c21313376.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 将这些怪兽全部以效果原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
