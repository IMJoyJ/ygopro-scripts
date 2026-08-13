--インフェルニティ・ビートル
-- 效果：
-- 自己手卡是0张的场合，可以把这张卡解放从自己卡组把最多2只「永火甲虫」特殊召唤。
function c49080532.initial_effect(c)
	-- 自己手卡是0张的场合，可以把这张卡解放从自己卡组把最多2只「永火甲虫」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49080532,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c49080532.condition)
	e1:SetCost(c49080532.cost)
	e1:SetTarget(c49080532.target)
	e1:SetOperation(c49080532.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查自己手牌数量是否为0。
function c49080532.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己手牌数量是否为0，作为效果可否发动的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义发动代价函数：确认这张卡可以解放，并将其解放作为发动代价。
function c49080532.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义卡组中「永火甲虫」的筛选条件：卡名是「永火甲虫」，且可以被特殊召唤。
function c49080532.filter(c,e,tp)
	return c:IsCode(49080532) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择函数：确认自己场上存在可用的怪兽区域（考虑解放后）且卡组中有符合条件的「永火甲虫」。
function c49080532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（解放后至少能空出1个区域，因此使用>-1进行宽松判定）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时确认卡组中存在至少1只符合筛选条件的「永火甲虫」可供特殊召唤，保证效果发动合法。
		and Duel.IsExistingMatchingCard(c49080532.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果从卡组特殊召唤1只怪兽（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数：若自己手牌仍为0，则根据可用区域数量选择并特殊召唤卡组中的「永火甲虫」（上限2只，受青眼精灵龙限制时降为1只）。
function c49080532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时复检：若自己手牌已不是0张，则效果不处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then return end
	-- 获取自己场上当前可用的主要怪兽区域数量，作为本次特殊召唤数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示信息，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1到ft张符合条件的「永火甲虫」，ft为可用区域数与2中的较小值（若青眼精灵龙在场则ft为1）。
	local g=Duel.SelectMatchingCard(tp,c49080532.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「永火甲虫」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
