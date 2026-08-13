--賢者の宝石
-- 效果：
-- ①：自己场上有「黑魔术少女」存在的场合才能发动。从手卡·卡组把1只「黑魔术师」特殊召唤。
function c13604200.initial_effect(c)
	-- 将本卡记载的卡名登记为黑魔术师(46986414)和黑魔术少女(38033121)，用于支持“记载有特定卡名”的相关规则判定。
	aux.AddCodeList(c,46986414,38033121)
	-- ①：自己场上有「黑魔术少女」存在的场合才能发动。从手卡·卡组把1只「黑魔术师」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c13604200.condition)
	e1:SetTarget(c13604200.target)
	e1:SetOperation(c13604200.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断卡片是否为表侧表示且卡名为黑魔术少女(38033121)。
function c13604200.cfilter(c)
	return c:IsFaceup() and c:IsCode(38033121)
end
-- 定义发动条件函数：检查我方场上是否存在1只以上表侧表示的黑魔术少女。
function c13604200.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上（LOCATION_ONFIELD，包含怪兽区和魔陷区）是否存在至少1张满足 cfilter 的卡，即表侧表示的黑魔术少女。
	return Duel.IsExistingMatchingCard(c13604200.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义可特殊召唤的卡片筛选函数：判断卡片是否为黑魔术师(46986414)，并且能否被我方以效果特殊召唤。
function c13604200.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动目标函数：在发动时（chk==0）确认存在空余的主要怪兽区，并且手卡/卡组中存在可以进行特殊召唤的黑魔术师。
function c13604200.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有空位，保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方手卡或卡组中是否存在至少1张满足 filter 条件（即黑魔术师且可特殊召唤）的卡。
		and Duel.IsExistingMatchingCard(c13604200.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本连锁的操作信息：本次效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），对象数量为1，可能来源为我方手卡或卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 定义效果处理函数：若主要怪兽区仍有空位，则从手卡/卡组选择1只黑魔术师，将其表侧表示特殊召唤到我方场上。
function c13604200.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍存在空位；若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”，用于后续选择卡片的交互界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方手卡/卡组中选择1张满足 filter 条件（黑魔术师且可特殊召唤）的卡，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c13604200.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示（POS_FACEUP）特殊召唤到我方场上，sumtype=0、不跳过召唤条件与苏生限制检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
