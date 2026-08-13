--CNo.43 魂魄傀儡鬼神カオス・マリオネッター
-- 效果：
-- 暗属性3星怪兽×4
-- ①：自己的衍生物在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡有「No.43 魂魄傀儡鬼 灵魂傀儡师」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「魂魄衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成对方基本分一半的数值。
function c32446630.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用4只暗属性3星怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,4)
	c:EnableReviveLimit()
	-- ①：自己的衍生物在同1次的战斗阶段中可以作2次攻击。（以永续效果使己方场上的衍生物获得额外攻击次数）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c32446630.atktg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.43 魂魄傀儡鬼 灵魂傀儡师」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除才能发动。在自己场上把1只「魂魄衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成对方基本分一半的数值。
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
-- 将该卡登记为No.43，使“No.”相关效果能够识别此卡。
aux.xyz_number[32446630]=43
-- ①效果的对象筛选：只有衍生物才适用额外攻击次数。
function c32446630.atktg(e,c)
	return c:IsType(TYPE_TOKEN)
end
-- ②效果的发动条件：这张卡的超量素材中存在卡号56051086（即「No.43 魂魄傀儡鬼 灵魂傀儡师」）时满足。
function c32446630.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,56051086)
end
-- 发动代价：取除这张卡的1个超量素材（REASON_COST）。
function c32446630.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动目标：检查能否在自己场上特殊召唤衍生物，并设置特殊召唤衍生物的操作信息。
function c32446630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位（用于特殊召唤衍生物）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否将「魂魄衍生物」（恶魔族·暗·1星·攻/守?）以表侧表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,32446631,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次效果将特殊召唤1只衍生物到自己的主要怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：本次效果包含生成衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,LOCATION_MZONE)
end
-- 效果处理：生成「魂魄衍生物」并特殊召唤，同时赋予其攻击力·守备力变为对方基本分一半数值的效果。
function c32446630.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有空位，若没有则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认玩家能否特殊召唤该衍生物，若不能则处理失败。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,32446631,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 创建「魂魄衍生物」（卡号32446631）。
	local token=Duel.CreateToken(tp,32446631)
	-- 通过特殊召唤步骤将衍生物以表侧攻击表示特殊召唤到自己场上。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 这衍生物的攻击力·守备力变成对方基本分一半的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		-- 设置攻击力为对方基本分的一半（向上取整）。
		e1:SetValue(math.ceil(Duel.GetLP(1-tp)/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
	end
	-- 完成一整套特殊召唤步骤，使衍生物正式上场。
	Duel.SpecialSummonComplete()
end
