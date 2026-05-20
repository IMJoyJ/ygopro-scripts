--幻蝶の刺客オオルリ
-- 效果：
-- 这张卡不能通常召唤。自己对战士族怪兽的召唤成功时，这张卡可以从手卡特殊召唤。这张卡不能作为同调素材。
function c54582424.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己对战士族怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54582424,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c54582424.spcon)
	e1:SetTarget(c54582424.sptg)
	e1:SetOperation(c54582424.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 判断是否为自己对战士族怪兽召唤成功。
function c54582424.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsRace(RACE_WARRIOR)
end
-- 特殊召唤效果的发动检测，要求自己场上有空余的怪兽区域，且这张卡可以特殊召唤。
function c54582424.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤并完成正规召唤程序。
function c54582424.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤，并无视召唤条件。
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
