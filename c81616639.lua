--ゾンビーナ
-- 效果：
-- ①：这张卡被对方破坏的场合，以「僵尸女孩」以外的自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
function c81616639.initial_effect(c)
	-- ①：这张卡被对方破坏的场合，以「僵尸女孩」以外的自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81616639,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c81616639.spcon)
	e1:SetTarget(c81616639.sptg)
	e1:SetOperation(c81616639.spop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：此卡在己方控制下被对方破坏
function c81616639.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤条件：4星以下、卡名非「僵尸女孩」且可以特殊召唤的怪兽
function c81616639.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and not c:IsCode(81616639) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查
function c81616639.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81616639.spfilter(chkc,e,tp) end
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的卡作为对象
		and Duel.IsExistingTarget(c81616639.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81616639.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽特殊召唤
function c81616639.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
