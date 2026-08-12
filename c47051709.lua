--フォトン・デルタ・ウィング
-- 效果：
-- ①：这张卡召唤的场合才能发动。从手卡·卡组把1只「光子三角翼飞机」守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是光属性怪兽不能特殊召唤。
-- ②：自己场上有其他的「光子三角翼飞机」存在的场合，对方不能攻击宣言。
local s,id,o=GetID()
-- 注册两个效果：①通常召唤成功时发动的特殊召唤效果和②对方不能攻击宣言的效果
function s.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从手卡·卡组把1只「光子三角翼飞机」守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是光属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上有其他的「光子三角翼飞机」存在的场合，对方不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否可以特殊召唤的「光子三角翼飞机」卡片
function s.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理函数，检查是否有满足条件的卡片可特殊召唤
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在符合条件的「光子三角翼飞机」
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1张「光子三角翼飞机」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理函数，执行特殊召唤并设置后续不能特殊召唤光属性以外怪兽的效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或卡组中选择一张「光子三角翼飞机」进行特殊召唤
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的卡片以守备表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 设置一个永续效果，使自己不能特殊召唤非光属性怪兽直到回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设定该效果的目标为非光属性的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsNonAttribute,ATTRIBUTE_LIGHT))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「光子三角翼飞机」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
-- 条件函数，判断是否满足②效果发动条件
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上有无其他「光子三角翼飞机」存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
