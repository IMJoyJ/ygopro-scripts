--魔導化士 マット
-- 效果：
-- 1回合1次，可以从卡组把1张名字带有「魔导书」的魔法卡送去墓地。这个效果发动的回合的结束阶段时，自己墓地的名字带有「魔导书」的魔法卡是5种类以上的场合，可以通过把这张卡解放，从卡组把1只魔法师族·暗属性·5星以上的怪兽特殊召唤。
function c63175639.initial_effect(c)
	-- 1回合1次，可以从卡组把1张名字带有「魔导书」的魔法卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63175639,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c63175639.sgtg)
	e1:SetOperation(c63175639.sgop)
	c:RegisterEffect(e1)
	-- 这个效果发动的回合的结束阶段时，自己墓地的名字带有「魔导书」的魔法卡是5种类以上的场合，可以通过把这张卡解放，从卡组把1只魔法师族·暗属性·5星以上的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63175639,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c63175639.spcon)
	e2:SetCost(c63175639.spcost)
	e2:SetTarget(c63175639.sptg)
	e2:SetOperation(c63175639.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中名字带有「魔导书」的魔法卡
function c63175639.filter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 送墓效果的发动准备，检查卡组中是否存在可送墓的「魔导书」魔法卡，设置操作信息，并给自身注册发动的标记
function c63175639.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以送去墓地的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c63175639.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	e:GetHandler():RegisterFlagEffect(63175639,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 送墓效果的处理，从卡组选择1张「魔导书」魔法卡送去墓地
function c63175639.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c63175639.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤墓地中名字带有「魔导书」的魔法卡
function c63175639.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 特殊召唤效果的发动条件，检查本回合是否发动过送墓效果，且墓地中「魔导书」魔法卡的种类是否在5种以上
function c63175639.spcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(63175639)==0 then return false end
	-- 获取自己墓地中所有名字带有「魔导书」的魔法卡
	local g=Duel.GetMatchingGroup(c63175639.cfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)>=5
end
-- 特殊召唤效果的代价处理，检查并解放自身
function c63175639.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可以特殊召唤的5星以上的魔法师族·暗属性怪兽
function c63175639.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽
function c63175639.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为代价会解放自身，所以可用空位数量需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查卡组中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c63175639.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理，从卡组选择1只满足条件的怪兽特殊召唤
function c63175639.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c63175639.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
