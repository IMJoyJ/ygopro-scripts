--エレメントセイバー・ナル
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·波涛」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c46425662.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·波涛」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46425662,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c46425662.thcost)
	e1:SetTarget(c46425662.thtg)
	e1:SetOperation(c46425662.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46425662,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c46425662.atttg)
	e2:SetOperation(c46425662.attop)
	c:RegisterEffect(e2)
end
-- 判断手卡/卡组的怪兽是否满足作为①效果发动代价的条件：属于「元素灵剑士」字段的怪兽卡，且可以作为代价送去墓地。
function c46425662.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价函数：先检测自己是否适用「灵神的圣殿」的效果，若有则将可送墓来源扩展为手卡或卡组；若无则仅手卡。然后从可选范围内选择1只满足costfilter的怪兽作为代价送去墓地；若选自卡组则同时使用「灵神的圣殿」的1回合1次次数。
function c46425662.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否受到卡号为61557074的「灵神的圣殿」的效果影响，以决定能否用卡组怪兽代替手卡送墓。
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 检查在当前状态下是否存在至少1张满足costfilter的卡可作为代价，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46425662.costfilter,tp,loc,0,1,nil) end
	-- 向操作玩家发出选择提示，要求选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从（手卡或卡组）可选范围内选出1张满足costfilter的卡，并取回该卡对象。
	local tc=Duel.SelectMatchingCard(tp,c46425662.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 当选择从卡组送墓时，展示「灵神的圣殿」的卡片动画，提示本次送墓是代替手卡发动其③效果。
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的卡片作为代价送入墓地。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 检索条件：自己墓地的「元素灵剑士」或「灵神」怪兽，且不是「元素灵剑士·波涛」自身，并且能够加入手卡。
function c46425662.thfilter(c)
	return c:IsSetCard(0x400d,0x113) and c:IsType(TYPE_MONSTER) and not c:IsCode(46425662) and c:IsAbleToHand()
end
-- ①效果的发动目标选择：从自己墓地选择1只符合条件的「元素灵剑士」/「灵神」怪兽作为对象（不能是本卡），并设置回手牌的操作信息。
function c46425662.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c46425662.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足thfilter条件的怪兽可以作为取对象目标，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c46425662.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示，要求选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地的可选怪兽中选择1只作为效果对象，同时将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c46425662.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的操作信息为回手牌（CATEGORY_TOHAND），对象为选中的怪兽g，数量为1，以此供其他卡（如星尘龙等）进行判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得发动时选择的目标，若该目标仍与效果关联，则将其加入手牌。
function c46425662.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的目标怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送去持有者的手牌（回手牌），原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动目标：无对象，宣言1个属性；宣言的属性存入效果标签，并设置该效果涉及墓地卡片离场的操作信息（用于王家长眠之谷等干扰判定）。
function c46425662.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家发出选择提示，要求宣言1个属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 由玩家从除本卡当前属性以外的全部属性中宣言1个属性，作为本回合要变成的属性。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置操作信息为涉及墓地卡片的离场效果（CATEGORY_LEAVE_GRAVE），对象为墓地中的本卡，用于响应相关效果（如王家长眠之谷）的判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ②效果处理：若本卡仍在墓地且未被连锁中断，则给本卡赋予一个改变属性的效果，使其在此回合结束时之前变为宣言的属性。
function c46425662.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
