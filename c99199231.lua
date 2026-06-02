--S－Force オリジン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·墓地·除外状态的1只「治安战警队」怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
-- ②：这张卡在墓地存在的状态，其他卡被除外的场合，把这张卡除外才能发动。从卡组选「治安战警队原点」以外的2张「治安战警队」卡，那之内的1张除外，另1张送去墓地。
local s,id,o=GetID()
-- 初始化效果：注册卡片发动时的特殊召唤效果，以及在墓地存在时因其他卡被除外而触发的卡组检索除外与送入墓地的效果
function s.initial_effect(c)
	-- ①：自己的手卡·墓地·除外状态的1只「治安战警队」怪兽特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，其他卡被除外的场合，把这张卡除外才能发动。从卡组选「治安战警队原点」以外的2张「治安战警队」卡，那之内的1张除外，另1张送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组操作"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	-- 设置效果发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否属于「治安战警队」字段，在手卡·墓地·除外区是否处于可特殊召唤的状态
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动时的Target函数，检查场上怪兽区是否有空位以及是否有可特殊召唤的「治安战警队」怪兽，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否可以容纳特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌、墓地、除外区是否存在满足条件的「治安战警队」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置本效果包含特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 卡片发动时的Operation函数，在手卡·墓地·除外区特殊召唤1只「治安战警队」怪兽，并为其注册离场时除外的限制效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认主要怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送请选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌、墓地或除外区选择1张不受王长谷影响且满足条件的「治安战警队」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。 / ②：这张卡在墓地存在的状态，其他卡被除外的场合，把这张卡除外才能发动。从卡组选「治安战警队原点」以外的2张「治安战警队」卡，那之内的1张除外，另1张送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
-- 墓地效果触发条件函数，检查被除外的卡片组中是否包含其他卡片
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查触发本次效果的除外卡片组中是否包含除了本卡之外的卡片
	return eg:IsExists(aux.TRUE,1,e:GetHandler())
end
-- 过滤函数：从卡组检索除了「治安战警队原点」以外的、且可被除外的「治安战警队」卡片，并检查卡组中是否存在另一张可被送入墓地的「治安战警队」卡片
function s.rmfilter(c,tp)
	return not c:IsCode(id) and c:IsSetCard(0x156) and c:IsAbleToRemove()
		-- 检查卡组中是否存在另一张能送去墓地的「治安战警队」卡片
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤函数：从卡组检索除了「治安战警队原点」以外的、且可以送去墓地的「治安战警队」卡片
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x156) and c:IsAbleToGrave()
end
-- 墓地效果发动的Target函数，检查卡组中是否存在可以除外和送入墓地的「治安战警队」卡片组合，并设置对应的送去墓地和除外的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在满足条件、可用于除外且有另外对应卡送入墓地的「治安战警队」卡片
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	-- 设置本效果包含从卡组把1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置本效果包含从卡组把1张卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 墓地效果发动的Operation函数，从卡组选择2张满足条件的「治安战警队」卡，将其中1张除外，另1张送去墓地
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送请选择要除外的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1张满足条件的「治安战警队」卡作为除外对象
	local tc1=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc1 then
		-- 向玩家发送请选择要送去墓地的卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择另1张满足条件的「治安战警队」卡作为送去墓地对象
		local tc2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,tc1):GetFirst()
		-- 将选择的第1张卡表侧表示除外
		Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)
		-- 将选择的第2张卡送去墓地
		Duel.SendtoGrave(tc2,REASON_EFFECT)
	end
end
