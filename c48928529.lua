--No.83 ギャラクシー・クィーン
-- 效果：
-- 1星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽直到对方回合结束时不会被战斗破坏，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c48928529.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用3只1星怪兽叠放来XYZ召唤（不限定种族/属性等条件）。
	aux.AddXyzProcedure(c,nil,1,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽直到对方回合结束时不会被战斗破坏，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48928529,0))  --"附加能力"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c48928529.cost)
	e1:SetOperation(c48928529.operation)
	c:RegisterEffect(e1)
end
-- 将这张卡登记为No.83，用于No.相关效果或规则的识别与判定。
aux.xyz_number[48928529]=83
-- 代价函数：发动前检查能否从这张卡上移除1个超量素材作为代价；确认可以后实际移除1个超量素材（REASON_COST）。
function c48928529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理函数：选择自己场上全部怪兽，分别给它们赋予“不会被战斗破坏”和“贯穿伤害”效果，持续到对方回合结束。
function c48928529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有怪兽区域的卡（包含主要怪兽区和额外怪兽区的怪兽）。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文“自己场上的全部怪兽直到对方回合结束时不会被战斗破坏”，为每只怪兽注册不会被战斗破坏的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 对应效果原文“向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害”，为每只怪兽注册贯穿伤害效果。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
