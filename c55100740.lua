--化合獣ハイドロン・ホーク
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●丢弃1张手卡，以自己墓地1只二重怪兽为对象才能发动。那只怪兽守备表示特殊召唤。「化合兽 氢素鹰」的这个效果1回合只能使用1次。
function c55100740.initial_effect(c)
	-- 为卡片添加二重怪兽的通用属性和规则（在场上·墓地当作通常怪兽，可再度召唤成为效果怪兽）
	aux.EnableDualAttribute(c)
	-- ●丢弃1张手卡，以自己墓地1只二重怪兽为对象才能发动。那只怪兽守备表示特殊召唤。「化合兽 氢素鹰」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55100740,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,55100740)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果的发动条件为该卡处于再度召唤状态（二重状态）
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c55100740.spcost)
	e1:SetTarget(c55100740.sptg)
	e1:SetOperation(c55100740.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价（Cost）函数：丢弃1张手卡
function c55100740.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在Cost检测阶段，检查玩家手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，让玩家选择手牌中的1张卡丢弃送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义过滤函数：筛选出可以守备表示特殊召唤的二重怪兽
function c55100740.filter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果的目标（Target）函数，用于检测发动条件、选择对象并声明操作信息
function c55100740.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55100740.filter(chkc,e,tp) end
	-- 在Target检测阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只满足特殊召唤条件的二重怪兽
		and Duel.IsExistingTarget(c55100740.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的二重怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c55100740.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的操作信息，声明此效果包含特殊召唤1个对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果的处理（Operation）函数，执行特殊召唤
function c55100740.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
