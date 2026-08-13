--ダークフレア・ドラゴン
-- 效果：
-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。1回合1次，可以从手卡和卡组把龙族怪兽各1只送去墓地，选择自己或者对方的墓地1张卡从游戏中除外。
function c25460258.initial_effect(c)
	-- 这张卡可以把自己墓地的光属性和暗属性的怪兽各1只从游戏中除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c25460258.spcon)
	e1:SetTarget(c25460258.sptg)
	e1:SetOperation(c25460258.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡和卡组把龙族怪兽各1只送去墓地，选择自己或者对方的墓地1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25460258,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c25460258.rmcost)
	e2:SetTarget(c25460258.rmtg)
	e2:SetOperation(c25460258.rmop)
	c:RegisterEffect(e2)
end
-- 特殊召唤的代价筛选函数：判断墓地中的怪兽是否可作为代价除外且属于光属性或暗属性，用于选择除外素材。
function c25460258.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件函数：确认自己场上有空余怪兽区，且墓地中存在光属性与暗属性怪兽各1只可作为除外代价，满足条件才允许从手卡进行规则特殊召唤。
function c25460258.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若自己没有空余的怪兽区域，则不允许进行特殊召唤。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有可作为除外代价的光/暗属性怪兽候选组。
	local g=Duel.GetMatchingGroup(c25460258.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查候选组中能否选出2张卡，使其中一张为光属性、另一张为暗属性，以满足除外条件。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤规则的选择/目标函数：让玩家从墓地候选组中选出光、暗属性怪兽各1只作为除外代价，保存选择结果并确认特殊召唤。
function c25460258.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次获取自己墓地中可作为除外代价的怪兽候选组，供玩家选择。
	local g=Duel.GetMatchingGroup(c25460258.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选组中让玩家选择2张卡，要求一张为光属性、另一张为暗属性；玩家可取消选择，取消则特殊召唤不进行。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的处理函数：将选中的光、暗属性怪兽各1只从墓地除外，完成特殊召唤手续。
function c25460258.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的2张素材怪兽以表侧表示从游戏中除外，作为特殊召唤的代价（REASON_SPSUMMON）。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 代价筛选函数：判断卡片是否为龙族怪兽且可作为代价送去墓地，用于选择手卡和卡组中要送墓的龙族。
function c25460258.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- 第二个效果的代价检查：确认手卡和卡组各存在至少1只符合条件的龙族怪兽，才能支付代价发动效果。
function c25460258.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中有至少1只符合条件的龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25460258.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 代价检查阶段：同时确认卡组中有至少1只符合条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(c25460258.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择1只符合条件的龙族怪兽，作为送墓代价。
	local g1=Duel.SelectMatchingCard(tp,c25460258.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 再次提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只符合条件的龙族怪兽，作为送墓代价。
	local g2=Duel.SelectMatchingCard(tp,c25460258.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	g1:Merge(g2)
	-- 将手卡和卡组中选出的龙族怪兽作为COST送去墓地。
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 第二个效果的目标选择函数：选择自己或对方墓地中1张可以除外的卡作为对象，并设置操作信息。
function c25460258.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 发动时检查自己或对方墓地是否存在1张可以被除外的卡，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己或对方墓地中选择1张可以被除外的卡，并登记为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local p=g:GetFirst():GetControler()
	-- 设置操作信息：本连锁将对所选择的墓地卡片执行除外操作（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,p,LOCATION_GRAVE)
end
-- 第二个效果的处理函数：取得对象卡，若该卡仍与效果关联，则将其从游戏中除外。
function c25460258.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外，除外原因为卡片效果（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
