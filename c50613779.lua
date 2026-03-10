--ダメージ・メイジ
-- 效果：
-- 卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
function c50613779.initial_effect(c)
	-- 卡的效果让自己受到伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50613779,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c50613779.spcon)
	e1:SetTarget(c50613779.sptg)
	e1:SetOperation(c50613779.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：造成伤害的玩家是自己，并且伤害是由效果造成的。
function c50613779.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 效果的发动准备阶段：检查自己场上是否有足够的怪兽区域，以及此卡是否可以被特殊召唤。
function c50613779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：将此卡特殊召唤到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息：使自己回复受到的伤害数值。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理阶段：如果此卡还在场上且成功特殊召唤，则回复对应数值的LP。
function c50613779.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与当前效果有关联，并尝试将其特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使自己回复由伤害效果造成的LP数值。
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
