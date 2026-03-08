--アポカテクイル
-- 效果：
-- 自己场上有调整表侧表示存在的场合，场上表侧表示存在的这张卡的等级当作5星使用。场上存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只「太阳之神官」特殊召唤。
function c41158734.initial_effect(c)
	-- 效果原文：自己场上有调整表侧表示存在的场合，场上表侧表示存在的这张卡的等级当作5星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetCondition(c41158734.lvcon)
	e1:SetValue(5)
	c:RegisterEffect(e1)
	-- 效果原文：场上存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只「太阳之神官」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(41158734,0))  --"特殊召唤"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c41158734.spcon)
	e2:SetTarget(c41158734.sptg)
	e2:SetOperation(c41158734.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的调整
function c41158734.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 条件函数：当自己场上有调整表侧表示存在时，该效果生效
function c41158734.lvcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的调整
	return Duel.IsExistingMatchingCard(c41158734.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 条件函数：当此卡因破坏而送去墓地时，该效果可以发动
function c41158734.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：检查墓地是否存在可特殊召唤的「太阳之神官」
function c41158734.spfilter(c,e,tp)
	return c:IsCode(42280216) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择目标函数：选择1只符合条件的「太阳之神官」作为特殊召唤目标
function c41158734.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41158734.spfilter(chkc,e,tp) end
	-- 判断阶段：检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断阶段：检查自己墓地是否存在符合条件的「太阳之神官」
		and Duel.IsExistingTarget(c41158734.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示信息：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从自己墓地选择1只「太阳之神官」作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c41158734.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将本次特殊召唤的卡和数量记录到连锁信息中
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的「太阳之神官」特殊召唤到场上
function c41158734.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡：获取本次效果选择的特殊召唤目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行特殊召唤：将目标卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
