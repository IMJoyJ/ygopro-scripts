--フォッシル・ダイナ パキケファロ
-- 效果：
-- ①：这张卡反转的场合发动。场上的特殊召唤的怪兽全部破坏。
-- ②：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
function c42009836.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
	-- ①：这张卡反转的场合发动。场上的特殊召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42009836,0))  --"特殊召唤的怪兽全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c42009836.target)
	e2:SetOperation(c42009836.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选特殊召唤的怪兽
function c42009836.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 设置效果目标为场上的特殊召唤怪兽，并设置破坏分类
function c42009836.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有特殊召唤的怪兽组成组
	local g=Duel.GetMatchingGroup(c42009836.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数，对满足条件的怪兽进行破坏
function c42009836.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有特殊召唤的怪兽组成组
	local g=Duel.GetMatchingGroup(c42009836.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将指定怪兽组以效果原因进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
