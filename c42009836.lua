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
-- 过滤条件：只选取以特殊召唤方式出场的怪兽，即特殊召唤怪兽。
function c42009836.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 诱发必发效果发动前的处理：效果必定满足发动条件，并登记本次破坏的对象信息。
function c42009836.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有特殊召唤怪兽组成的卡组，作为预定破坏的对象集合。
	local g=Duel.GetMatchingGroup(c42009836.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁的处理信息登记为破坏这些怪兽，数量为当前取得的怪兽数，供其他效果或时点判断。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 诱发效果处理时的实际执行：再次获取场上全部特殊召唤怪兽，并将其全部破坏。
function c42009836.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取双方场上当前存在的所有特殊召唤怪兽，避免使用发动时保存的过时集合。
	local g=Duel.GetMatchingGroup(c42009836.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将这些怪兽全部破坏送入墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
