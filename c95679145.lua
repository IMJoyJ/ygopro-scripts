--教導の大神祇官
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只融合·同调·超量·连接怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己的额外卡组把2只卡名不同的怪兽送去墓地。对方从自身的额外卡组把2只怪兽送去墓地。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
function c95679145.initial_effect(c)
	-- ①：从自己墓地把1只融合·同调·超量·连接怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95679145,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,95679145)
	e1:SetCost(c95679145.spcost)
	e1:SetTarget(c95679145.sptg)
	e1:SetOperation(c95679145.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的额外卡组把2只卡名不同的怪兽送去墓地。对方从自身的额外卡组把2只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95679145,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,95679146)
	e2:SetTarget(c95679145.tgtg)
	e2:SetOperation(c95679145.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以作为代价除外的融合、同调、超量、连接怪兽
function c95679145.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- ①号效果的发动代价（Cost）处理函数
function c95679145.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95679145.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c95679145.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的发动准备（Target）处理函数
function c95679145.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理（Operation）函数
function c95679145.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动准备（Target）处理函数
function c95679145.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己额外卡组中可以送去墓地的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
	-- 获取对方额外卡组中可以送去墓地的卡片
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	-- 在发动时，检查自己额外卡组是否存在2张卡名不同的卡，且对方额外卡组是否至少有2张卡
	if chk==0 then return g:CheckSubGroup(aux.dncheck,2,2) and g2:GetCount()>1 end
end
-- ②号效果的效果处理（Operation）函数
function c95679145.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组中可以送去墓地的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
	-- 提示自己玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己额外卡组选择2张卡名不同的卡片
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg and sg:GetCount()==2 then
		-- 将自己选择的2张卡片送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 获取对方额外卡组中可以送去墓地的卡片
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	-- 提示对方玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg2=g2:Select(1-tp,2,2,nil)
	if sg2:GetCount()==2 then
		-- 将对方选择的2张卡片送去墓地
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95679145.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能从额外卡组特殊召唤怪兽”的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的来源区域为额外卡组
function c95679145.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
