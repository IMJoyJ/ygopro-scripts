--No.82 ハートランドラコ
-- 效果：
-- 4星怪兽×2
-- ①：只要自己场上有魔法卡表侧表示存在，对方不能选择这张卡作为攻击对象。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，其他的自己怪兽不能攻击，这张卡可以直接攻击。
function c31437713.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽进行叠放，需要2只怪兽
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 只要自己场上有魔法卡表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c31437713.atkcon)
	-- 设置效果值为aux.imval1函数，用于判断是否不会成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这个回合，其他的自己怪兽不能攻击，这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31437713,0))  --"直接攻击"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31437713.condition)
	e2:SetCost(c31437713.cost)
	e2:SetOperation(c31437713.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为82
aux.xyz_number[31437713]=82
-- 过滤函数，用于判断场上是否有表侧表示的魔法卡
function c31437713.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 条件函数，判断自己场上有魔法卡表侧表示存在
function c31437713.atkcon(e)
	-- 检查以自己为玩家，在场上是否存在至少1张满足filter条件的卡
	return Duel.IsExistingMatchingCard(c31437713.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 条件函数，判断回合玩家能否进入战斗阶段且该卡未具有直接攻击效果
function c31437713.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段且该卡未具有直接攻击效果
	return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 费用函数，检查是否能从自己场上取除1个超量素材作为代价
function c31437713.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标过滤函数，用于排除特定字段ID的怪兽
function c31437713.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果发动时，为场上所有自己怪兽添加不能攻击的效果，并为该卡添加直接攻击效果
function c31437713.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=0
	if c:IsRelateToEffect(e) then fid=c:GetFieldID() end
	-- 为场上所有自己怪兽添加不能攻击的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c31437713.ftarget)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到全局环境，影响指定玩家
	Duel.RegisterEffect(e1,tp)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 为该卡添加直接攻击效果
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
