--灼熱工の巨匠カエン
-- 效果：
-- 把自己墓地存在的这张卡从游戏中除外发动。自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升400。
function c51554871.initial_effect(c)
	-- 把自己墓地存在的这张卡从游戏中除外发动。自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51554871,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c51554871.target)
	e1:SetOperation(c51554871.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在表侧表示且卡名含「熔岩」的怪兽
function c51554871.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 效果的target阶段，检查自己场上是否存在满足filter条件的怪兽
function c51554871.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果chk==0（即检查阶段），则返回自己场上是否存在至少1张满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51554871.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果的发动阶段，检索满足条件的怪兽组并为它们加上攻击力上升400的效果
function c51554871.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足filter条件的怪兽组成group
	local g=Duel.GetMatchingGroup(c51554871.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	while tc do
		-- 使目标怪兽的攻击力上升400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
