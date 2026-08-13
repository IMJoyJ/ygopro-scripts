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
-- 发动条件判定：我方受到效果伤害时才能发动，即受到伤害的玩家是自己且伤害原因为效果伤害。
function c50613779.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 发动合法性检查：确认我方主要怪兽区有空位，且这张卡自身可以被特殊召唤，以此判断效果能否发动。
function c50613779.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非效果处理时（chk==0）的发动条件判断：确认我方主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向连锁系统登记本次效果的特殊召唤信息：表示效果处理时会将这张卡从手卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 向连锁系统登记本次效果的回复信息：表示效果处理时我方将回复与该次伤害数值等量的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理：先尝试将这张卡从手卡特殊召唤；若特殊召唤成功，则我方回复与受到的伤害数值等量的基本分。
function c50613779.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤处理：确认这张卡仍与本次效果有关联，并尝试将其从手卡以表侧表示特殊召唤到我方怪兽区；特殊召唤成功后才继续执行回复。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 回复处理：我方回复与受到的伤害值等量的基本分，该回复视为由卡的效果造成。
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
