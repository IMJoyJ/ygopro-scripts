--電磁石の戦士マグネット・ベルセリオン
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上·墓地把「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只除外的场合可以特殊召唤。
-- ①：从自己墓地把1只4星以下的「磁石战士」怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以除外的自己的「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
function c42901635.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤。从自己的手卡·场上·墓地把「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42901635.spcon)
	e1:SetTarget(c42901635.sptg)
	e1:SetOperation(c42901635.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：从自己墓地把1只4星以下的「磁石战士」怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c42901635.cost)
	e2:SetTarget(c42901635.target)
	e2:SetOperation(c42901635.activate)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡被战斗或者对方的效果破坏的场合，以除外的自己的「电磁石战士α」「电磁石战士β」「电磁石战士γ」各1只为对象才能发动。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c42901635.spcon2)
	e3:SetTarget(c42901635.sptg2)
	e3:SetOperation(c42901635.spop2)
	c:RegisterEffect(e3)
end
-- 创建一个检查函数数组，用于验证是否满足特殊召唤条件，即从手牌、场上或墓地各除外一张电磁石战士α、β、γ卡片。
c42901635.spchecks=aux.CreateChecks(Card.IsCode,{42023223,79418928,15502037})
-- 定义一个过滤函数，用于筛选手牌、场上或墓地中的电磁石战士α、β、γ卡片，这些卡片可以作为特殊召唤的除外代价。
function c42901635.spcostfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsAbleToRemoveAsCost() and c:IsCode(42023223,79418928,15502037)
end
-- 检查函数，判断当前玩家是否满足特殊召唤条件，即是否有足够的电磁石战士α、β、γ卡片可以除外。
function c42901635.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家手牌、场上和墓地中的所有电磁石战士α、β、γ卡片。
	local g=Duel.GetMatchingGroup(c42901635.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 验证获取的卡片组中是否存在满足特殊召唤条件的子组，即每种卡片各一张。
	return g:CheckSubGroupEach(c42901635.spchecks,aux.mzctcheck,tp)
end
-- 设置特殊召唤的目标选择函数，用于选择要除外的电磁石战士α、β、γ卡片。
function c42901635.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌、场上和墓地中的所有电磁石战士α、β、γ卡片。
	local g=Duel.GetMatchingGroup(c42901635.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的卡片中选择满足特殊召唤条件的子组。
	local sg=g:SelectSubGroupEach(tp,c42901635.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，将选中的卡片除外。
function c42901635.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片以特殊召唤的形式除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义一个过滤函数，用于筛选墓地中的4星以下的磁石战士怪兽，这些卡片可以作为破坏效果的除外代价。
function c42901635.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToRemoveAsCost()
end
-- 设置破坏效果的费用处理函数，用于选择并除外墓地中的磁石战士怪兽。
function c42901635.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足破坏效果的费用条件，即墓地中是否存在至少一张符合条件的磁石战士怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c42901635.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择一张符合条件的磁石战士怪兽。
	local g=Duel.SelectMatchingCard(tp,c42901635.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以费用的形式除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置破坏效果的目标选择函数，用于选择对方场上的卡。
function c42901635.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否满足破坏效果的目标选择条件，即对方场上是否存在至少一张卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡作为破坏目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息，用于记录破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将选中的卡破坏。
function c42901635.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设置特殊召唤效果的触发条件，即该卡被战斗或对方效果破坏。
function c42901635.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 定义一个过滤函数，用于筛选已除外的电磁石战士α、β、γ卡片，这些卡片可以被特殊召唤。
function c42901635.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(42023223,79418928,15502037)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 设置特殊召唤效果的目标选择函数，用于选择要特殊召唤的电磁石战士卡片。
function c42901635.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取当前玩家已除外的电磁石战士α、β、γ卡片。
	local g=Duel.GetMatchingGroup(c42901635.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 检查是否满足特殊召唤效果的触发条件，即是否有足够的怪兽区空位和符合条件的卡片。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and g:CheckSubGroupEach(c42901635.spchecks) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroupEach(tp,c42901635.spchecks)
	-- 设置特殊召唤效果的操作信息，用于记录特殊召唤的卡。
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤效果的操作信息，用于记录特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- 执行特殊召唤效果的操作，根据玩家的怪兽区空位数量决定是否特殊召唤所有符合条件的卡。
function c42901635.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家的怪兽区空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁的目标卡组，并筛选出与效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()<=ft then
		-- 将符合条件的卡以特殊召唤的形式召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的卡以特殊召唤的形式召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将未被特殊召唤的卡以规则原因送入墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
