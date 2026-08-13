--ミラー・レディバグ
-- 效果：
-- 自己场上有表侧表示怪兽1只以上存在，自己墓地没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，这张卡的等级变成这张卡以外的自己场上存在的怪兽的等级合计的等级。此外，场上表侧表示存在的这张卡的等级超过12的场合，这张卡破坏。
function c45358284.initial_effect(c)
	-- 自己场上有表侧表示怪兽1只以上存在，自己墓地没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45358284.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，这张卡的等级变成这张卡以外的自己场上存在的怪兽的等级合计的等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45358284,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c45358284.lvcon)
	e2:SetOperation(c45358284.lvop)
	c:RegisterEffect(e2)
	-- 此外，场上表侧表示存在的这张卡的等级超过12的场合，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c45358284.descon)
	c:RegisterEffect(e3)
end
-- 特殊召唤的规则条件：判定这张卡是否满足从手卡特殊召唤的条件——自己场上有表侧表示怪兽存在、自己墓地没有怪兽，且场上存在空的怪兽区域。
function c45358284.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在空的怪兽区域，用于放置从手卡特殊召唤的这张卡。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示怪兽，满足条件“自己场上有表侧表示怪兽1只以上存在”。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地不存在怪兽卡，满足条件“自己墓地没有怪兽存在”。
		and	not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 判定这次特殊召唤是否为这张卡自身的规则效果（SUMMON_VALUE_SELF）所产生的特殊召唤，从而只在该效果特殊召唤成功时触发等级变化。
function c45358284.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 等级变化处理：若这张卡仍与效果相关，则取得自己场上除这张卡以外的表侧表示怪兽并合计等级；若合计不为0，给这张卡赋予等级变为该数值的效果。
function c45358284.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得自己场上除这张卡以外的所有表侧表示怪兽，用于计算等级合计。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	local lvs=g:GetSum(Card.GetLevel)
	if lvs~=0 then
		-- 这张卡的等级变成这张卡以外的自己场上存在的怪兽的等级合计的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lvs)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判定这张卡当前的等级是否大于12，若是则执行自我破坏（不入连锁的破坏）。
function c45358284.descon(e)
	return e:GetHandler():GetLevel()>12
end
