--『焔聖剣－ジョワユーズ』
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡装备中的场合，以自己墓地1只战士族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。那之后，这张卡破坏。
-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合才能发动。从手卡把1只战士族·炎属性怪兽特殊召唤。
function c90861137.initial_effect(c)
	-- 「焰圣剑-咎瓦尤斯」的卡片发动与装备效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c90861137.target)
	e1:SetOperation(c90861137.operation)
	c:RegisterEffect(e1)
	-- 装备限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡装备中的场合，以自己墓地1只战士族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。那之后，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90861137,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,90861137)
	e3:SetTarget(c90861137.thtg)
	e3:SetOperation(c90861137.thop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合才能发动。从手卡把1只战士族·炎属性怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90861137,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,90861137)
	e4:SetCondition(c90861137.spcon)
	e4:SetTarget(c90861137.sptg)
	e4:SetOperation(c90861137.spop)
	c:RegisterEffect(e4)
end
-- 卡片发动时的对象选择与效果处理准备
function c90861137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理（将这张卡装备给目标怪兽）
function c90861137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤自己墓地的战士族·炎属性且能加入手卡的怪兽
function c90861137.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果①的发动准备与对象选择
function c90861137.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c90861137.thfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的战士族·炎属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c90861137.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地1只战士族·炎属性怪兽作为对象
	local g=Duel.SelectTarget(tp,c90861137.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（回收怪兽并破坏自身）
function c90861137.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要加入手牌的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍适用效果，并将其加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 中断效果处理，使后续的破坏处理不与加入手牌同时进行（造成错时点）
		Duel.BreakEffect()
		-- 破坏这张卡
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 效果②的发动条件判定（装备怪兽被送去墓地导致这张卡失去装备对象而送去墓地）
function c90861137.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_GRAVE)
end
-- 过滤手卡中可以特殊召唤的战士族·炎属性怪兽
function c90861137.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果②的发动准备与可行性检查
function c90861137.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在可以特殊召唤的战士族·炎属性怪兽
		and Duel.IsExistingMatchingCard(c90861137.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理（从手卡特殊召唤怪兽）
function c90861137.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的战士族·炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c90861137.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
