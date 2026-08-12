--ナチュル・チェリー
-- 效果：
-- 这张卡被对方从场上送去墓地的场合，可以从自己卡组把最多2只「自然樱桃」里侧守备表示特殊召唤。
function c60668166.initial_effect(c)
	-- 这张卡被对方从场上送去墓地的场合，可以从自己卡组把最多2只「自然樱桃」里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60668166,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c60668166.condition)
	e1:SetTarget(c60668166.target)
	e1:SetOperation(c60668166.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：由对方操作将这张卡从场上送去墓地
function c60668166.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡名为「自然樱桃」且可以里侧守备表示特殊召唤的怪兽
function c60668166.filter(c,e,tp)
	return c:IsCode(60668166) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动目标：检查怪兽区域空位与卡组中是否存在可特召的「自然樱桃」，并设置特殊召唤的操作信息
function c60668166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检查自己卡组是否存在至少1只满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c60668166.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤（预估数量为1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：计算可特召数量，从卡组选择最多2只「自然樱桃」里侧守备表示特殊召唤，并让对方确认
function c60668166.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的最大数量（取自己场上空位与2的较小值）
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1到ct只满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c60668166.filter,tp,LOCATION_DECK,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 给对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
