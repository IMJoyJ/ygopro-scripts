--マタタビ仙狸
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡解放，以「木天蓼仙狸」以外的自己墓地1只2星怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽属性不同的1只2星怪兽从手卡特殊召唤。
function c13382806.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡解放，以「木天蓼仙狸」以外的自己墓地1只2星怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽属性不同的1只2星怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,13382806)
	e1:SetCost(c13382806.cost)
	e1:SetTarget(c13382806.target)
	e1:SetOperation(c13382806.operation)
	c:RegisterEffect(e1)
end
-- 作为发动代价：需要解放这张卡；chk==0时检查这张卡是否可解放，若可则执行解放。
function c13382806.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价形式将这张卡解放（送入墓地）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 墓地候补怪兽的过滤条件：可被特殊召唤、等级为2、卡名不是「木天蓼仙狸」。
function c13382806.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(2) and not c:IsCode(13382806)
end
-- 发动目标的判定与选择：验证对象卡是否为自己墓地的2星怪兽且满足特殊召唤条件；并检查有没有空位以及是否存在符合条件的对象。
function c13382806.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13382806.spfilter(chkc,e,tp) end
	-- 检查本卡（解放后）的怪兽区是否有空余位置。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的2星怪兽（非「木天蓼仙狸」）可以作为对象。
		and Duel.IsExistingTarget(c13382806.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的2星怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c13382806.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁的操作信息：包含特殊召唤效果，对象为已选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 手卡候补怪兽的过滤条件：可被特殊召唤、等级为2、属性与已特殊召唤的怪兽不同。
function c13382806.spfilter2(c,e,tp,attr)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(2) and not c:IsAttribute(attr)
end
-- 效果处理：若怪兽区有空位，则将对象怪兽特殊召唤；成功后若手卡存在可特殊召唤且属性不同的2星怪兽，并且仍有空位，则询问玩家是否继续从手卡特殊召唤。
function c13382806.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己怪兽区没有空位，则立即结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得以这张卡为对象的效果处理时的对象卡（墓地那只2星怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与该效果关联，则将其以表侧攻击表示特殊召唤，并确认是否成功。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查手卡是否存在1只可特殊召唤、2星、且属性与已特殊召唤怪兽不同的怪兽。
		and Duel.IsExistingMatchingCard(c13382806.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetAttribute())
		-- 确认怪兽区仍有空位，并询问玩家是否从手卡特殊召唤1只2星怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(13382806,0)) then  --"是否从手卡特殊召唤2星怪兽？"
		-- 中断当前效果处理，使接下来的特殊召唤与之前的处理不是同一时点（错开时点）。
		Duel.BreakEffect()
		-- 弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只满足条件的2星怪兽（可特殊召唤、属性不同）。
		local sg=Duel.SelectMatchingCard(tp,c13382806.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetAttribute())
		-- 将选择的手卡怪兽以表侧攻击表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
