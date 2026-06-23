--No.83 ギャラクシー・クィーン
-- 效果：
-- 1星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部怪兽直到对方回合结束时不会被战斗破坏，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c48928529.initial_effect(c)
	-- 添加XYZ召唤手续，使用1星怪兽3只进行叠放
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
-- 设置该卡的XYZ编号为83
aux.xyz_number[48928529]=83
-- 费用处理函数：检查并移除1个超量素材作为发动代价
function c48928529.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理函数：为己方场上所有怪兽赋予不会被战斗破坏和贯穿伤害效果
function c48928529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的所有怪兽组成一个组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local tc=g:GetFirst()
	while tc do
		-- 使该怪兽直到对方回合结束时不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		-- 向守备表示怪兽攻击时造成超出其守备力的战斗伤害
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
