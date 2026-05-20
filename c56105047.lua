--ゴゴゴゴースト
-- 效果：
-- 这张卡特殊召唤成功的场合，可以选择自己墓地1只「隆隆隆石人」表侧守备表示特殊召唤。那之后，这张卡变成守备表示。「隆隆隆幽灵」的效果1回合只能使用1次。
function c56105047.initial_effect(c)
	-- 这张卡特殊召唤成功的场合，可以选择自己墓地1只「隆隆隆石人」表侧守备表示特殊召唤。那之后，这张卡变成守备表示。「隆隆隆幽灵」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56105047,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,56105047)
	e1:SetTarget(c56105047.sptg)
	e1:SetOperation(c56105047.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以表侧守备表示特殊召唤的「隆隆隆石人」
function c56105047.filter(c,e,tp)
	return c:IsCode(62476815) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与合法性检测
function c56105047.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56105047.filter(chkc,e,tp) end
	-- 检测自己墓地是否存在符合条件的「隆隆隆石人」
	if chk==0 then return Duel.IsExistingTarget(c56105047.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检测自己场上是否有可用于特殊召唤的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「隆隆隆石人」作为效果的对象
	local g=Duel.SelectTarget(tp,c56105047.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c56105047.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍符合条件，则将其表侧守备表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==1 then
		if c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的改变表示形式不与特殊召唤同时处理
			Duel.BreakEffect()
			-- 将这张卡（隆隆隆幽灵）变成守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
