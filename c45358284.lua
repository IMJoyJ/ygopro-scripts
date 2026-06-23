--ミラー・レディバグ
-- 效果：
-- 自己场上有表侧表示怪兽1只以上存在，自己墓地没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，这张卡的等级变成这张卡以外的自己场上存在的怪兽的等级合计的等级。此外，场上表侧表示存在的这张卡的等级超过12的场合，这张卡破坏。
function c45358284.initial_effect(c)
	-- 特殊召唤条件效果，满足条件时可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45358284.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 特殊召唤成功时，这张卡的等级变成这张卡以外的自己场上存在的怪兽的等级合计的等级
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45358284,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c45358284.lvcon)
	e2:SetOperation(c45358284.lvop)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡的等级超过12的场合，这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c45358284.descon)
	c:RegisterEffect(e3)
end
-- 检查是否满足特殊召唤条件：场上存在空位、自己场上存在表侧表示怪兽、自己墓地没有怪兽
function c45358284.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在怪兽
		and	not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 判断是否为特殊召唤成功
function c45358284.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 获取自己场上所有表侧表示怪兽的等级总和，并设置为当前怪兽的等级
function c45358284.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	local lvs=g:GetSum(Card.GetLevel)
	if lvs~=0 then
		-- 设置当前怪兽的等级为指定值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lvs)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断当前怪兽等级是否超过12
function c45358284.descon(e)
	return e:GetHandler():GetLevel()>12
end
