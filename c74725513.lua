--ホルスの加護－ケベンセヌフ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。这个回合中，对方怪兽不能把「荷鲁斯」怪兽作为攻击对象，对方不能把场上的「荷鲁斯」怪兽作为效果的对象。
function c74725513.initial_effect(c)
	-- 记录这张卡的效果中记载了「王之棺」的卡名
	aux.AddCodeList(c,16528181)
	-- ①：自己场上有「王之棺」存在的场合，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,74725513+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c74725513.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己场上的其他卡因对方的效果从场上离开的场合才能发动。这个回合中，对方怪兽不能把「荷鲁斯」怪兽作为攻击对象，对方不能把场上的「荷鲁斯」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74725513,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,74725514)
	e2:SetCondition(c74725513.descon)
	e2:SetOperation(c74725513.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且卡名为「王之棺」的卡
function c74725513.sprfilter(c)
	return c:IsFaceup() and c:IsCode(16528181)
end
-- 特殊召唤规则的条件：不受「王家长眠之谷」影响，且自己场上有可用的怪兽区域，且自己场上存在「王之棺」
function c74725513.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「王之棺」
		and Duel.IsExistingMatchingCard(c74725513.sprfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：原本由自己控制、因对方的效果而从场上离开的卡
function c74725513.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果发动的条件：自己场上除这张卡以外的其他卡因对方的效果从场上离开
function c74725513.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74725513.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：表侧表示的「荷鲁斯」怪兽
function c74725513.atlimit(e,c)
	return c:IsSetCard(0x19d) and c:IsFaceup()
end
-- 效果处理：本回合中，对方怪兽不能把「荷鲁斯」怪兽作为攻击对象，对方不能把场上的「荷鲁斯」怪兽作为效果的对象
function c74725513.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，对方怪兽不能把「荷鲁斯」怪兽作为攻击对象
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c74725513.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能选择「荷鲁斯」怪兽作为攻击对象的效果
	Duel.RegisterEffect(e1,tp)
	-- 对方不能把场上的「荷鲁斯」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c74725513.atlimit)
	-- 设置不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能成为对方卡片效果对象的效果
	Duel.RegisterEffect(e2,tp)
end
