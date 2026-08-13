--TG ハルバード・キャノン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽以及对方场上的特殊召唤的怪兽全部除外。
-- ②：场上的这张卡被破坏时，以自己墓地1只「科技属 戟炮手」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
function c47027714.initial_effect(c)
	-- 注册本卡效果文本中提到的「爆裂模式」的卡号80280737，用于在规则上标记这张卡记载了《爆裂模式》的卡名。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件限制设置为爆裂体通用判定函数：只允许通过「爆裂模式」的效果进行特殊召唤，不允许其他召唤方式。
	e0:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e0)
	-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际才能发动。那个无效，那些怪兽以及对方场上的特殊召唤的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47027714)
	e1:SetCondition(c47027714.rmcon)
	e1:SetTarget(c47027714.rmtg)
	e1:SetOperation(c47027714.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被破坏时，以自己墓地1只「科技属 戟炮手」为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47027714,2))
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,47027715)
	e4:SetCondition(c47027714.spcon)
	e4:SetTarget(c47027714.sptg)
	e4:SetOperation(c47027714.spop)
	c:RegisterEffect(e4)
end
c47027714.assault_name=97836203
-- 效果①的发动条件判定：必须是对方玩家进行召唤·反转召唤·特殊召唤之际，且当前不处于连锁处理中（直接连锁召唤行为），才能发动。
function c47027714.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当触发事件的玩家不是效果控制者（对方进行召唤）且当前连锁数为0，确保效果只能在对方召唤的时点直接发动。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- ①效果的发动目标与操作信息设定：将被无效的召唤怪兽组与对方场上所有特殊召唤怪兽合并，并分别写入「无效召唤」和「除外」两类操作信息。
function c47027714.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 从本次欲无效的召唤怪兽组eg中筛选出所有卡（排除本卡自身），构成将被特殊处理的对象集合g。
	local g=eg:Filter(aux.TRUE,nil,e:GetHandler())
	-- 获取对方场上所有以特殊召唤方式召唤出来的怪兽，作为①效果中「对方场上的特殊召唤的怪兽」的除外对象。
	local g2=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	g:Merge(g2)
	-- 设置操作信息：将本次效果的“无效召唤”分类与正在被召唤的怪兽组（eg）关联，并记录数量，供其他连锁/效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将本次效果的“除外”分类与待除外的怪兽组（g）关联，并记录数量，供连锁判定和效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 执行①效果：先使该次召唤无效，再把被无效的召唤怪兽以及对方场上所有特殊召唤的怪兽全部表侧除外。
function c47027714.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前发动的这次召唤·反转召唤·特殊召唤无效，召唤的怪兽不会成功上场。
	Duel.NegateSummon(eg)
	local g=eg:Clone()
	-- 获取对方场上其余特殊召唤怪兽（排除已经被无效的本次召唤组），用于合并后一并除外。
	local g2=Duel.GetMatchingGroup(Card.IsSummonType,tp,0,LOCATION_MZONE,g,SUMMON_TYPE_SPECIAL)
	g:Merge(g2)
	-- 将收集到的全部怪兽（被无效召唤的怪兽＋对方场上特殊召唤的怪兽）以表侧表示除外，是①效果的最终除外操作。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
-- ②效果的发动条件判定：这张卡在被破坏之前位于场上（即作为场上的卡被破坏），满足时②效果才能发动。
function c47027714.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤选择对象：目标必须是墓地中的「科技属 戟炮手」（卡号97836203），且能够被特殊召唤（nocheck=true不检查召唤条件，nolimit=false仍需满足苏生限制）。
function c47027714.spfilter(c,e,tp)
	return c:IsCode(97836203) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的目标处理：先确认己方怪兽区有空位且墓地有符合条件的「科技属 戟炮手」，然后选择1只作为对象，并设置特殊召唤的操作信息。
function c47027714.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47027714.spfilter(chkc,e,tp) end
	-- 效果发动合法性检查：自己场上必须有至少1个空余怪兽区域，才能发动②效果以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足过滤条件（「科技属 戟炮手」且可特殊召唤）的怪兽，两者都满足时②效果才能发动。
		and Duel.IsExistingTarget(c47027714.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示选择提示，提示文本为“请选择要特殊召唤的卡”，用于后续选择目标时明确操作目的。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「科技属 戟炮手」作为效果对象，并将其设置为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c47027714.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 写入连锁操作信息：本次效果将进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为已选择的卡g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果：确认对象仍然存在且与效果相关联后，将其无视召唤条件以表侧表示特殊召唤到自己场上。
function c47027714.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的目标怪兽（墓地中的「科技属 戟炮手」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标「科技属 戟炮手」以表侧表示特殊召唤到自己场上，指定不检查召唤条件（仍受苏生限制），完成②效果的处理。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
