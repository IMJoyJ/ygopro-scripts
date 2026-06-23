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
-- 用于筛选场上可以被解放的光属性或地属性战士族怪兽，需满足种族为战士族、属性为光或地、正面表示且有可用怪兽区。
function c25449584.spfilter(c,tp)
	-- 筛选场上可以被解放的光属性或地属性战士族怪兽，需满足种族为战士族、属性为光或地、正面表示且有可用怪兽区。
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足，检查场上是否存在可解放的光属性或地属性战士族怪兽。
function c25449584.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在可解放的光属性或地属性战士族怪兽。
	return Duel.CheckReleaseGroupEx(tp,c25449584.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤时选择解放怪兽的处理逻辑，提示玩家选择要解放的怪兽。
function c25449584.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组，并筛选出满足条件的光属性或地属性战士族怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c25449584.spfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤后的处理，包括解放怪兽、设置出场方式提示及根据解放怪兽的攻击力提升自身攻击力。
function c25449584.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将指定怪兽从场上解放。
	Duel.Release(tc,REASON_SPSUMMON)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(25449584,1))  --"出场方式为特殊召唤"
	local atk=tc:GetBaseAttack()
	if atk<0 then return end
	-- 设置自身攻击力增加解放怪兽的原本攻击力数值的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 用于筛选墓地中可除外的战士族怪兽。
function c25449584.rmfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
-- 设置效果发动时的费用支付处理，需要从墓地除外1只战士族怪兽。
function c25449584.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少1只战士族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25449584.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择从墓地除外的1只战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c25449584.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从墓地除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 用于筛选卡组中可送去墓地的光属性或地属性战士族怪兽。
function c25449584.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 设置效果发动时的目标选择处理，检查卡组中是否存在满足条件的怪兽。
function c25449584.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只光属性或地属性战士族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c25449584.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将从卡组选择1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理，从卡组选择1只光属性或地属性战士族怪兽送去墓地。
function c25449584.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只光属性或地属性战士族怪兽。
	local g=Duel.SelectMatchingCard(tp,c25449584.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
