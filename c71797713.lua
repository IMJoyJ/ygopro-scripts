--エレメントセイバー・ウィラード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把2只其他怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的「元素灵剑士」怪兽以及「灵神」怪兽受为这张卡的①的效果发动而送去墓地的「元素灵剑士」怪兽的原本属性对应的以下所适用。
-- ●地或者风：不会被战斗破坏。
-- ●水或者炎：不会被效果破坏。
-- ●光或者暗：不会成为对方的效果的对象。
function c71797713.initial_effect(c)
	-- ①：从手卡把2只其他怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71797713,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71797713)
	e1:SetCost(c71797713.spcost)
	e1:SetTarget(c71797713.sptg)
	e1:SetOperation(c71797713.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「元素灵剑士」怪兽以及「灵神」怪兽受为这张卡的①的效果发动而送去墓地的「元素灵剑士」怪兽的原本属性对应的以下所适用。●地或者风：不会被战斗破坏。●水或者炎：不会被效果破坏。●光或者暗：不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c71797713.regcon)
	e2:SetOperation(c71797713.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 过滤作为发动代价送去墓地的怪兽（手卡的怪兽，或在特定场地魔法适用时为卡组的「元素灵剑士」怪兽）
function c71797713.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and (c:IsSetCard(0x400d) or c:IsLocation(LOCATION_HAND))
end
-- 过滤原本属性包含指定属性的「元素灵剑士」怪兽
function c71797713.regfilter(c,attr)
	return c:IsSetCard(0x400d) and bit.band(c:GetOriginalAttribute(),attr)~=0
end
-- 特殊召唤效果的代价处理，选择2只怪兽送去墓地并根据送去墓地的「元素灵剑士」怪兽的原本属性记录标记值
function c71797713.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到「灵神圣殿」效果的影响（允许从卡组将「元素灵剑士」送去墓地）
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 检查是否存在至少2张满足条件的卡作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c71797713.costfilter,tp,loc,0,2,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择2张满足条件的卡作为代价
	local g=Duel.SelectMatchingCard(tp,c71797713.costfilter,tp,loc,0,2,2,e:GetHandler())
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		-- 提示发动了「灵神圣殿」的效果
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	local flag=0
	if g:IsExists(c71797713.regfilter,1,nil,ATTRIBUTE_EARTH+ATTRIBUTE_WIND) then flag=bit.bor(flag,0x1) end
	if g:IsExists(c71797713.regfilter,1,nil,ATTRIBUTE_WATER+ATTRIBUTE_FIRE) then flag=bit.bor(flag,0x2) end
	if g:IsExists(c71797713.regfilter,1,nil,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) then flag=bit.bor(flag,0x4) end
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(flag)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及自身是否可以特殊召唤
function c71797713.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理，将自身特殊召唤
function c71797713.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤，并带上自身效果召唤的标记
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查是否是通过自身效果特殊召唤成功，且代价中存在对应属性的「元素灵剑士」怪兽
function c71797713.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and e:GetLabelObject():GetLabel()~=0
end
-- 根据代价中「元素灵剑士」怪兽的属性，为自己场上的「元素灵剑士」和「灵神」怪兽注册相应的抗性效果
function c71797713.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	-- ●地或者风：不会被战斗破坏。●水或者炎：不会被效果破坏。●光或者暗：不会成为对方的效果的对象。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c71797713.immtg)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD)
	if bit.band(flag,0x1)~=0 then
		local e1=e0:Clone()
		e1:SetDescription(aux.Stringid(71797713,1))  --"使用地·风特殊召唤"
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		local e2=e0:Clone()
		e2:SetDescription(aux.Stringid(71797713,2))  --"使用水·炎特殊召唤"
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		c:RegisterEffect(e2)
	end
	if bit.band(flag,0x4)~=0 then
		local e3=e0:Clone()
		e3:SetDescription(aux.Stringid(71797713,3))  --"使用光·暗特殊召唤"
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置不会成为对方效果对象的效果值（过滤对方玩家的效果）
		e3:SetValue(aux.tgoval)
		c:RegisterEffect(e3)
	end
end
-- 过滤抗性效果的适用对象（自己场上的「元素灵剑士」怪兽以及「灵神」怪兽）
function c71797713.immtg(e,c)
	return c:IsSetCard(0x400d,0x113)
end
