--リビルディア
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时，以自己墓地1只攻击力1500以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c4550066.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时，以自己墓地1只攻击力1500以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4550066,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 检测本次战斗是否满足效果发动条件，即此卡是否与对方怪兽战斗并破坏了对方怪兽
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c4550066.sptg)
	e1:SetOperation(c4550066.spop)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽：电子界族、攻击力1500以下、可以特殊召唤
function c4550066.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsAttackBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件：选择满足条件的墓地怪兽作为对象，并确保场上存在召唤区域
function c4550066.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c4550066.spfilter(chkc,e,tp) end
	-- 检查是否满足发动条件：墓地存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c4550066.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查是否满足发动条件：场上存在召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4550066.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：确定将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤到场上
function c4550066.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
