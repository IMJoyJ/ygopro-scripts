--ヴォルカニック・ブレイズ・キャノン
-- 效果：
-- 从手卡·卡组·场上（表侧表示）把1张「烈焰加农炮」送去墓地才能把这张卡发动。
-- ①：「火山烈焰加农炮」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只「火山」怪兽特殊召唤。
-- ③：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。从卡组把1只炎族·1星怪兽送去墓地，作为对象的怪兽破坏。
function c85250352.initial_effect(c)
	c:SetUniqueOnField(1,0,85250352)
	-- 从手卡·卡组·场上（表侧表示）把1张「烈焰加农炮」送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c85250352.cost)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只「火山」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85250352,0))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c85250352.sptg)
	e2:SetOperation(c85250352.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。从卡组把1只炎族·1星怪兽送去墓地，作为对象的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85250352,1))  --"对方怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c85250352.destg)
	e3:SetOperation(c85250352.desop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡·卡组·场上表侧表示的「烈焰加农炮」且能送去墓地
function c85250352.costfilter(c)
	return c:IsFaceupEx() and c:IsCode(69537999) and c:IsAbleToGraveAsCost()
end
-- 发动卡片时的代价处理：从手卡·卡组·场上（表侧表示）将1张「烈焰加农炮」送去墓地
function c85250352.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动卡片时，检查手卡·卡组·场上（表侧表示）是否存在至少1张可以作为代价送去墓地的「烈焰加农炮」
	if chk==0 then return Duel.IsExistingMatchingCard(c85250352.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张手卡·卡组·场上（表侧表示）的「烈焰加农炮」
	local g=Duel.SelectMatchingCard(tp,c85250352.costfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：手卡中可以特殊召唤的「火山」怪兽
function c85250352.spfilter(c,e,tp)
	return c:IsSetCard(0x32) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与检查
function c85250352.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在可以特殊召唤的「火山」怪兽
		and Duel.IsExistingMatchingCard(c85250352.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理
function c85250352.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只手卡中的「火山」怪兽
	local g=Duel.SelectMatchingCard(tp,c85250352.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可以送去墓地的炎族·1星怪兽
function c85250352.disfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_PYRO) and c:IsAbleToGrave()
end
-- 过滤条件：表侧表示的怪兽
function c85250352.desfilter(c)
	return c:IsFaceup()
end
-- 破坏效果的发动准备、对象选择与检查
function c85250352.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c85250352.desfilter(chkc) end
	-- 在发动效果时，检查卡组中是否存在可以送去墓地的炎族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85250352.disfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查对方场上是否存在可以作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(c85250352.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85250352.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：破坏选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送墓并破坏效果的处理
function c85250352.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择卡组中1只炎族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,c85250352.disfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地，并检查是否成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
