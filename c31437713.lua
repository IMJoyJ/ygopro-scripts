--No.82 ハートランドラコ
-- 效果：
-- 4星怪兽×2
-- ①：只要自己场上有魔法卡表侧表示存在，对方不能选择这张卡作为攻击对象。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，其他的自己怪兽不能攻击，这张卡可以直接攻击。
function c31437713.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只等级4的怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：只要自己场上有魔法卡表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c31437713.atkcon)
	-- 设置该效果的Value函数为aux.imval1，使此卡获得“不能成为攻击对象”的判定（对方怪兽若不免疫此效果则不能选择攻击此卡）。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，其他的自己怪兽不能攻击，这张卡可以直接攻击。
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
-- 登记该卡的No.号为82，用于“No.”卡相关规则判定。
aux.xyz_number[31437713]=82
-- 定义筛选条件：表侧表示且为魔法卡的卡片，用于检测自己场上是否存在表侧魔法卡。
function c31437713.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果①的适用条件：自己场上有表侧表示魔法卡存在时，该保护效果适用。
function c31437713.atkcon(e)
	-- 检查自己场上是否存在至少1张表侧表示魔法卡。
	return Duel.IsExistingMatchingCard(c31437713.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动条件：当前可进入战斗阶段，且此卡尚未获得直接攻击效果。
function c31437713.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足“可以进入战斗阶段”且此卡没有直接攻击效果，作为效果②的发动条件。
	return Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果②的发动代价：取除此卡的1个超量素材。
function c31437713.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 作为“不能攻击”效果的目标过滤：除发动效果的这张卡（用FieldID标识）以外的自己怪兽才会受到不能攻击效果影响。
function c31437713.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②处理：对自己场上除这张卡以外的怪兽赋予本回合不能攻击的誓约效果；若这张卡仍表侧且与效果关联，再赋予本回合可直接攻击的效果。
function c31437713.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=0
	if c:IsRelateToEffect(e) then fid=c:GetFieldID() end
	-- 这个回合，其他的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c31437713.ftarget)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该“不能攻击”效果注册到tp方全场，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡可以直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
