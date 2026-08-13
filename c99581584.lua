--ガード・ペンギン
-- 效果：
-- 卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
function c99581584.initial_effect(c)
	-- 卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99581584,0))  --"特殊召唤并回复"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c99581584.spcon)
	e1:SetTarget(c99581584.sptg)
	e1:SetOperation(c99581584.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤并回复LP的诱发效果在满足条件时才能发动：伤害来自效果且受到伤害的是这张卡的控制者。
function c99581584.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 效果发动时检查：自己主要怪兽区有空位且这张卡能够被特殊召唤。
function c99581584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记特殊召唤的操作信息：将这张卡本身作为特殊召唤对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 登记回复的操作信息：预计回复受到伤害的数值（ev），对象暂不确定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理时，如果这张卡仍与效果关联且特殊召唤成功，则回复LP。
function c99581584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍有联系且成功特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 根据受到的伤害数值回复自己基本分。
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
