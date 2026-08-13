--地葬星カイザ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己场上1只光属性或者地属性的战士族怪兽解放从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力上升解放的怪兽的原本攻击力数值。
-- ②：从自己墓地把1只战士族怪兽除外才能发动。从卡组把1只光属性或者地属性的战士族怪兽送去墓地。
function c25449584.initial_effect(c)
	-- ①：这张卡可以把自己场上1只光属性或者地属性的战士族怪兽解放从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,25449584+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c25449584.spcon)
	e1:SetTarget(c25449584.sptg)
	e1:SetOperation(c25449584.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把1只战士族怪兽除外才能发动。从卡组把1只光属性或者地属性的战士族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25449584,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25449585)
	e2:SetCost(c25449584.tgcost)
	e2:SetTarget(c25449584.tgtg)
	e2:SetOperation(c25449584.tgop)
	c:RegisterEffect(e2)
end
-- 筛选可作为解放素材的怪兽：必须是光属性或地属性的表侧表示的战士族怪兽，且将其解放后我方场上有空余的怪兽区。
function c25449584.spfilter(c,tp)
	-- 判定该怪兽是否为光/地属性表侧战士族，且解放它后我方场上仍有可用怪兽区。
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 规则特殊召唤的条件：若c为空（规则查询）则允许；否则检查我方场上是否存在至少1只满足条件的可解放怪兽。
function c25449584.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1只满足spfilter条件且可作为特殊召唤解放的怪兽。
	return Duel.CheckReleaseGroupEx(tp,c25449584.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的处理：从可解放的怪兽组中选出1只符合条件的怪兽作为解放素材，选中则记录并允许特殊召唤，否则不允许。
function c25449584.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可控的、可用于特殊召唤解放的怪兽组，并筛选出满足spfilter的候选怪兽集合。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c25449584.spfilter,nil,tp)
	-- 向玩家发出选择解放素材的提示消息：请选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理时：解放选中的怪兽，为本卡标记客户端提示，并根据解放怪兽的原本攻击力提升本卡攻击力。
function c25449584.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选择的怪兽解放（作为特殊召唤手续的一部分）。
	Duel.Release(tc,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(25449584,1))  --"出场方式为特殊召唤"
	local atk=tc:GetBaseAttack()
	if atk<0 then return end
	-- 这个方法特殊召唤的这张卡的攻击力上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 筛选可作为②效果发动代价的怪兽：战士族且可以被除外。
function c25449584.rmfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己墓地选1只战士族怪兽除外；若不存在则不能发动。
function c25449584.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己墓地是否存在至少1只满足rmfilter的怪兽作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c25449584.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择除外怪兽的提示消息：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足rmfilter的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c25449584.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 筛选卡组中可被送去墓地的怪兽：光/地属性的战士族怪兽，且可以被送去墓地。
function c25449584.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- ②效果的发动目标：确认卡组中存在符合条件的战士族怪兽，并设置效果处理时将卡片送去墓地的信息。
function c25449584.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1只满足tgfilter的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25449584.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为从卡组把1只怪兽送去墓地（确定数量1，持有者为自己，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时：从卡组选1只符合条件的战士族怪兽送去墓地。
function c25449584.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择送去墓地的怪兽的提示消息：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足tgfilter的战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c25449584.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片送去墓地（由效果处理送去）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
