--X－セイバー エアベルン
-- 效果：
-- ①：这张卡直接攻击给与对方战斗伤害的场合发动。对方手卡随机选1张丢弃。
function c90508760.initial_effect(c)
	-- ①：这张卡直接攻击给与对方战斗伤害的场合发动。对方手卡随机选1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90508760,0))  --"丢弃手牌"
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c90508760.condition)
	e1:SetTarget(c90508760.target)
	e1:SetOperation(c90508760.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：判断是否满足直接攻击给与对方战斗伤害的条件
function c90508760.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否是对方受到伤害（ep~=tp）且没有攻击目标（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义效果发动目标函数：因为是必发效果，直接返回true，并设置丢弃手牌的操作信息
function c90508760.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：对方手牌减少1张
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 定义效果运行函数：随机选择对方1张手牌并丢弃
function c90508760.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的手牌组
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的卡片以效果丢弃的原因送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
