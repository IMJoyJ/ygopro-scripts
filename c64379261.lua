--ゴルゴニック・ガーゴイル
-- 效果：
-- 自己对岩石族怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
function c64379261.initial_effect(c)
	-- 自己对岩石族怪兽的召唤成功时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64379261,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c64379261.spcon)
	e1:SetTarget(c64379261.sptg)
	e1:SetOperation(c64379261.spop)
	c:RegisterEffect(e1)
end
-- 检查是否为自己成功通常召唤了岩石族怪兽
function c64379261.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsRace(RACE_ROCK)
end
-- 检查发动条件：自己场上有空余的怪兽区域，且这张卡可以特殊召唤
function c64379261.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为将1张自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若这张卡仍在手卡，则将其特殊召唤
function c64379261.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
