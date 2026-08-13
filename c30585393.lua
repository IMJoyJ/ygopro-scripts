--リボーン・パズル
-- 效果：
-- 只让自己场上的怪兽1只被卡的效果破坏的场合，选择那1只才能发动。选择的怪兽在自己场上特殊召唤。
function c30585393.initial_effect(c)
	-- 只让自己场上的怪兽1只被卡的效果破坏的场合，选择那1只才能发动。选择的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c30585393.target)
	e1:SetOperation(c30585393.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：被效果破坏的怪兽只有1只，且该怪兽破坏前由自己控制、曾位于主要怪兽区，破坏后位于墓地或除外区、破坏原因为效果，并且能够成为效果对象、能够被特殊召唤，自己场上主要怪兽区有空位。
function c30585393.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return eg:GetCount()==1 and tc:IsPreviousControler(tp) and tc:IsPreviousLocation(LOCATION_MZONE)
		-- 确认自己场上主要怪兽区有可用的空格，以满足特殊召唤条件。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and tc:IsReason(REASON_EFFECT)
		and tc:IsCanBeEffectTarget(e) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将选择的那1只怪兽设为当前连锁的对象，使其成为效果处理时的取对象目标。
	Duel.SetTargetCard(tc)
	-- 设置本连锁的特殊召唤操作信息：预定将对象怪兽1只特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 效果处理：取得之前选择的对象怪兽，若该怪兽仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c30585393.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时对象怪兽（应为发动时选择的那1只）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
