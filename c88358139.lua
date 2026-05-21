--EMヘルプリンセス
-- 效果：
-- ①：自己对「娱乐伙伴 帮助公主」以外的「娱乐伙伴」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
function c88358139.initial_effect(c)
	-- ①：自己对「娱乐伙伴 帮助公主」以外的「娱乐伙伴」怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c88358139.spcon)
	e1:SetTarget(c88358139.sptg)
	e1:SetOperation(c88358139.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：由自己召唤·特殊召唤的「娱乐伙伴 帮助公主」以外的「娱乐伙伴」怪兽
function c88358139.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x9f) and not c:IsCode(88358139)
end
-- 发动条件：检查当前召唤·特殊召唤的怪兽中是否存在满足条件的怪兽
function c88358139.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88358139.cfilter,1,nil,tp)
end
-- 效果发动：检查自身是否能特殊召唤到自己的主要怪兽区域
function c88358139.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果存在联系，则将此卡特殊召唤
function c88358139.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
