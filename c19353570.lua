--影無茶ナイト
-- 效果：
-- 自己对3星怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这张卡不能作为同调素材。
function c19353570.initial_effect(c)
	-- 自己对3星怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19353570,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19353570.spcon)
	e1:SetTarget(c19353570.sptg)
	e1:SetOperation(c19353570.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 诱发条件判定：仅当召唤成功的怪兽是己方（rp==tp）且为3星等级时，效果才能发动。
function c19353570.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:GetFirst():IsLevel(3)
end
-- 发动时点合法检测：需要自己主要怪兽区有空位，且这张卡自身能够被特殊召唤。
function c19353570.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次操作信息：预定将这张卡特殊召唤，以便后续连锁/效果能够正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：取得效果持有者，若该卡仍与效果关联（未离场/未被无效化）则执行特殊召唤。
function c19353570.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到己方场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
