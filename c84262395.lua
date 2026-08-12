--地縛解放
-- 效果：
-- ①：场上有6星以上的怪兽召唤·特殊召唤时，把自己场上1只10星「地缚」怪兽解放才能发动。对方场上的怪兽全部破坏，给与对方破坏的怪兽的原本攻击力合计数值的伤害。
local s,id,o=GetID()
-- 注册卡片效果：在场上有6星以上的怪兽召唤·特殊召唤时，解放自己场上1只10星「地缚」怪兽发动，破坏对方场上所有怪兽并给予对方伤害
function s.initial_effect(c)
	-- ①：场上有6星以上的怪兽召唤时，把自己场上1只10星「地缚」怪兽解放才能发动。对方场上的怪兽全部破坏，给与对方破坏的怪兽的原本攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且等级在6星以上的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(6)
end
-- 发动条件：检查本次召唤·特殊召唤的怪兽中是否存在满足过滤条件的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
-- 过滤条件：等级10的「地缚」怪兽
function s.cfilter(c)
	return c:IsLevel(10) and c:IsSetCard(0x21)
end
-- 发动代价：解放自己场上1只10星「地缚」怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的10星「地缚」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil) end
	-- 选择自己场上1只10星「地缚」怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果的目标处理：检查对方场上是否有怪兽，并设置破坏与伤害的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if chk==0 then return #g>0 end
	-- 设置破坏操作信息，包含对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置伤害操作信息，数值为对方场上怪兽的原本攻击力合计
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetSum(Card.GetBaseAttack))
end
-- 效果的运行处理：破坏对方场上的怪兽，并给予对方相当于被破坏怪兽原本攻击力合计数值的伤害
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 破坏对方场上的怪兽，若没有怪兽被破坏则不处理后续伤害效果
	if Duel.Destroy(g,REASON_EFFECT)<1 then return end
	-- 计算实际被破坏怪兽的原本攻击力合计数值
	local dam=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
	-- 给予对方该合计数值的伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end
