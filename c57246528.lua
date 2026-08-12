--シンクロ・トランセンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只同调怪兽为对象才能发动。把持有比那只怪兽高1星的等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
function c57246528.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只同调怪兽为对象才能发动。把持有比那只怪兽高1星的等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,57246528+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c57246528.target)
	e1:SetOperation(c57246528.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示的同调怪兽，且额外卡组存在比其等级高1星、可特殊召唤的同调怪兽
function c57246528.opfilter(c,e,tp)
	-- 检查卡片是否表侧表示、是同调怪兽，且额外卡组中存在至少1张满足特殊召唤条件的、等级比其高1星的同调怪兽
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c57246528.tpfilter,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),e,tp)
end
-- 过滤额外卡组中等级为指定等级+1、可以特殊召唤的同调怪兽，且额外怪兽区域有可用位置
function c57246528.tpfilter(c,lv,e,tp)
	-- 检查卡片是否是同调怪兽、等级是否为指定等级+1、是否能被特殊召唤，且额外怪兽区域有可用位置
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的目标选择与检测函数
function c57246528.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c57246528.opfilter(chkc,e,tp) end
	-- 在发动时，检查对方场上是否存在符合条件的表侧表示同调怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c57246528.opfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只符合条件的表侧表示同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57246528.opfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（发动）函数
function c57246528.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 设置选择卡片时的提示信息为选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只比对象怪兽等级高1星的同调怪兽
	local sg=Duel.SelectMatchingCard(tp,c57246528.tpfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetLevel(),e,tp):GetFirst()
	-- 如果成功选择怪兽，则将其以表侧表示特殊召唤（分步处理）
	if sg and Duel.SpecialSummonStep(sg,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(57246528,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sg:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
