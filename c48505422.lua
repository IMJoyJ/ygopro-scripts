--真六武衆－シナイ
-- 效果：
-- 自己场上有「真六武众-瑞穂」表侧表示存在的场合，这张卡可以从手卡特殊召唤。场上存在的这张卡被解放的场合，选择自己墓地存在的「真六武众-竹刀」以外的1只名字带有「六武众」的怪兽加入手卡。
function c48505422.initial_effect(c)
	-- 自己场上有「真六武众-瑞穂」表侧表示存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c48505422.spcon)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被解放的场合，选择自己墓地存在的「真六武众-竹刀」以外的1只名字带有「六武众」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48505422,0))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCondition(c48505422.rlcon)
	e2:SetTarget(c48505422.rltg)
	e2:SetOperation(c48505422.rlop)
	c:RegisterEffect(e2)
end
-- 检查怪兽是否表侧表示且卡号为74094021（「真六武众-瑞穂」），用于检索场上满足条件的「真六武众-瑞穂」。
function c48505422.spfilter(c)
	return c:IsFaceup() and c:IsCode(74094021)
end
-- 该效果作为手卡特殊召唤规则时的发动条件：需要我方主要怪兽区有空位，且我方场上有表侧表示的「真六武众-瑞穂」。
function c48505422.spcon(e,c)
	if c==nil then return true end
	-- 检查我方主要怪兽区是否存在可用的空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查我方场上是否存在1张满足spfilter过滤条件的表侧表示「真六武众-瑞穂」。
		Duel.IsExistingMatchingCard(c48505422.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 诱发效果的条件判定：这张卡被解放前所在的位置是场上，即作为场上存在的这张卡被解放。
function c48505422.rlcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 墓地检索的过滤条件：是名字带有「六武众」的怪兽、不是这张卡自身、是怪兽且可以加入手卡。
function c48505422.filter(c)
	return c:IsSetCard(0x103d) and not c:IsCode(48505422) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的目标选择处理：检查墓地是否存在满足filter的「六武众」怪兽，若有则提示玩家选择1张对象，并设置取对象回手牌的操作信息。
function c48505422.rltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48505422.filter(chkc) end
	-- 在效果发动时（非选择对象阶段）检查墓地是否存在至少1只满足filter的「六武众」怪兽，判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c48505422.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示文字，用于选择卡片时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足filter的「六武众」怪兽（除外这张卡自身）作为效果对象。
	local g=Duel.SelectTarget(tp,c48505422.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息，告知系统将由该效果把对象卡加入手牌，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时获取对象，若对象与效果仍有关联，则将其送去手牌并向对方确认。
function c48505422.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果原因返回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张加入手卡的卡片，使其确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
