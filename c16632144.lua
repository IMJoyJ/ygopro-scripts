--屈強の釣り師
-- 效果：
-- ①：这张卡直接攻击给与对方战斗伤害时，以自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c16632144.initial_effect(c)
	-- 创建效果①，为诱发选发效果，触发时点为造成战斗伤害，取对象，特殊召唤类别
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16632144,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c16632144.spcon)
	e1:SetTarget(c16632144.sptg)
	e1:SetOperation(c16632144.spop)
	c:RegisterEffect(e1)
end
-- 效果①的发动条件：本次战斗伤害是由对方造成的且攻击怪兽没有攻击目标
function c16632144.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 本次战斗伤害是由对方造成的且攻击怪兽没有攻击目标
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 筛选满足特殊召唤条件的墓地怪兽
function c16632144.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动时的处理：判断是否满足发动条件并选择目标
function c16632144.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16632144.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c16632144.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c16632144.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的发动效果处理：将选中的墓地怪兽特殊召唤
function c16632144.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
