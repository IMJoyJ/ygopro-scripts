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
	-- 设置发动代价为把这张卡从墓地除外（aux.bfgcost实现了除外自身作为COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c51554871.target)
	e1:SetOperation(c51554871.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：卡为表侧表示且卡名属于「熔岩」字段（0x39）。
function c51554871.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 发动条件判断：确认自己场上有满足条件的表侧表示「熔岩」怪兽，且效果可以发动。
function c51554871.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查自己场上是否存在至少1张满足过滤条件的「熔岩」怪兽，作为效果发动的合法性依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c51554871.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取场上所有符合条件的「熔岩」怪兽，逐个赋予攻击力上升400的效果。
function c51554871.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且名字带有「熔岩」的怪兽集合。
	local g=Duel.GetMatchingGroup(c51554871.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	while tc do
		-- 自己场上表侧表示存在的名字带有「熔岩」的怪兽的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
