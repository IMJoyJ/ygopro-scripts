--CNo.43 魂魄傀儡鬼神カオス・マリオネッター
-- 效果：
-- 暗属性3星怪兽×4
-- ①：自己的衍生物在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡有「No.43 魂魄傀儡鬼 灵魂傀儡师」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「魂魄衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成对方基本分一半的数值。
function c32446630.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用满足暗属性条件的3星怪兽4只作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,4)
	c:EnableReviveLimit()
	-- 自己的衍生物在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c32446630.atktg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡有「No.43 魂魄傀儡鬼 灵魂傀儡师」在作为超量素材的场合，得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32446630,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32446630.condition)
	e2:SetCost(c32446630.cost)
	e2:SetTarget(c32446630.target)
	e2:SetOperation(c32446630.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为43
aux.xyz_number[32446630]=43
-- 效果适用对象为衍生物
function c32446630.atktg(e,c)
	return c:IsType(TYPE_TOKEN)
end
-- 效果发动条件：场上有「No.43 魂魄傀儡鬼 灵魂傀儡师」作为超量素材
function c32446630.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,56051086)
end
-- 效果发动代价：从场上取除1个超量素材
function c32446630.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时点：判定是否可以特殊召唤衍生物
function c32446630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32446631,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置连锁操作信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
	-- 设置连锁操作信息：召唤衍生物token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,LOCATION_MZONE)
end
-- 效果发动处理：判断是否可以特殊召唤衍生物并设置其攻击力守备力
function c32446630.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,32446631,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创造一个指定编号的衍生物token
	local token=Duel.CreateToken(tp,32446631)
	-- 开始特殊召唤衍生物token步骤
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置衍生物的攻击力为对方基本分一半的数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		-- 设置衍生物的攻击力为对方基本分一半的数值
		e1:SetValue(math.ceil(Duel.GetLP(1-tp)/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
	end
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
end
