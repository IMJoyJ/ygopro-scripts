--エヴォルテクター エヴェック
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡召唤·特殊召唤成功的场合，以「真化护法 主教」以外的自己墓地1只战士族·炎属性怪兽或者二重怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的这个效果1回合只能使用1次。
function c16146511.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16146511,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16146511)
	-- 效果的发动条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c16146511.sptg)
	e1:SetOperation(c16146511.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地怪兽：战士族·炎属性或二重怪兽且不是此卡本身且可以特殊召唤
function c16146511.spfilter(c,e,tp)
	return ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or c:IsType(TYPE_DUAL)) and not c:IsCode(16146511) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件和目标选择逻辑
function c16146511.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16146511.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c16146511.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c16146511.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，包括特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将选中的怪兽特殊召唤
function c16146511.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
