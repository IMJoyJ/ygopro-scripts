--有翼幻獣キマイラ
-- 效果：
-- 「幻兽王 加泽尔」＋「巴风特」
-- ①：这张卡被破坏时，以自己墓地1只「幻兽王 加泽尔」或「巴风特」为对象才能发动。那只怪兽特殊召唤。
function c4796100.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「幻兽王 加泽尔」和「巴风特」为融合素材。
	aux.AddFusionProcCode2(c,5818798,77207191,true,true)
	-- ①：这张卡被破坏时，以自己墓地1只「幻兽王 加泽尔」或「巴风特」为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4796100,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(c4796100.sptg)
	e1:SetOperation(c4796100.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤的筛选函数：判断卡片是否为「幻兽王 加泽尔」或「巴风特」，且能够被特殊召唤。
function c4796100.spfilter(c,e,tp)
	return c:IsCode(5818798,77207191) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象目标判定与发动条件检查：对象必须是自己墓地的「幻兽王 加泽尔」或「巴风特」且可被特殊召唤；同时自己场上需要有可用怪兽区。
function c4796100.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4796100.spfilter(chkc,e,tp) end
	-- 效果发动时检查自己主要怪兽区是否有空位，以确定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足筛选条件的可特殊召唤的怪兽。
		and Duel.IsExistingTarget(c4796100.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足筛选条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c4796100.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息：将选择的怪兽作为特殊召唤的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时取得对象怪兽，若仍与效果关联，则将其表侧表示特殊召唤到自己怪兽区。
function c4796100.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
