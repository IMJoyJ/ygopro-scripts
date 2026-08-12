--素早いアンコウ
-- 效果：
-- 这张卡从手卡·卡组送去墓地的场合，可以从卡组把「迅捷鮟鱇」以外的最多2只3星以下的名字带有「迅捷」的怪兽特殊召唤。
function c88686573.initial_effect(c)
	-- 这张卡从手卡·卡组送去墓地的场合，可以从卡组把「迅捷鮟鱇」以外的最多2只3星以下的名字带有「迅捷」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88686573,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c88686573.condition)
	e1:SetTarget(c88686573.target)
	e1:SetOperation(c88686573.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡送去墓地前的位置是否是手卡或卡组
function c88686573.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 过滤卡组中「迅捷鮟鱇」以外的、3星以下的名字带有「迅捷」且可以特殊召唤的怪兽
function c88686573.filter(c,e,tp)
	return c:IsSetCard(0x78) and not c:IsCode(88686573) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置
function c88686573.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c88686573.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组特殊召唤最多2只满足条件的怪兽
function c88686573.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1到ft张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c88686573.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
