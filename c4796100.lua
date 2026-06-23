--有翼幻獣キマイラ
-- 效果：
-- 「幻兽王 加泽尔」＋「巴风特」
-- ①：这张卡被破坏时，以自己墓地1只「幻兽王 加泽尔」或「巴风特」为对象才能发动。那只怪兽特殊召唤。
function c4796100.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号5818798和77207191的怪兽作为融合素材
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
-- 过滤满足条件的墓地怪兽，必须是「幻兽王 加泽尔」或「巴风特」且可以特殊召唤
function c4796100.spfilter(c,e,tp)
	return c:IsCode(5818798,77207191) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的处理目标，选择满足条件的墓地怪兽作为特殊召唤对象
function c4796100.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4796100.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地中是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c4796100.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为效果处理目标
	local g=Duel.SelectTarget(tp,c4796100.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上
function c4796100.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果处理目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
