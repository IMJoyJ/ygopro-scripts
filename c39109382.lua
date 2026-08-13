--機皇創出
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「机皇」怪兽加入手卡。
-- ②：丢弃1张手卡，以自己场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：自己场上的表侧表示的「机皇」怪兽被战斗·效果破坏的场合，以这张卡以外的场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
function c39109382.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「机皇」怪兽加入手卡。（同时体现「这个卡名的卡在1回合只能发动1张」的限制）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39109382+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c39109382.activate)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡，以自己场上1只怪兽为对象才能发动。那只怪兽破坏。（同时体现「这个卡名的②的效果1回合各能使用1次」的限制）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39109382,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,39109382+100)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c39109382.descost)
	e2:SetTarget(c39109382.destg)
	e2:SetOperation(c39109382.desop)
	c:RegisterEffect(e2)
	-- ③：自己场上的表侧表示的「机皇」怪兽被战斗·效果破坏的场合，以这张卡以外的场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。（同时体现「这个卡名的③的效果1回合各能使用1次」的限制）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39109382,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,39109382+200)
	e3:SetCondition(c39109382.descon2)
	e3:SetTarget(c39109382.destg2)
	e3:SetOperation(c39109382.desop)
	c:RegisterEffect(e3)
end
-- 检索过滤器：判断卡组中的卡是否为「机皇」怪兽且能够加入手卡。
function c39109382.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13) and c:IsAbleToHand()
end
-- ①效果处理：从卡组选择1只「机皇」怪兽加入手卡，并让对方确认。
function c39109382.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足检索条件的「机皇」怪兽。
	local g=Duel.GetMatchingGroup(c39109382.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在可检索的「机皇」怪兽且玩家选择“是”，则继续执行加入手卡处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39109382,0)) then  --"是否从卡组把1只「机皇」怪兽加入手卡？"
		-- 显示“选择要加入手牌的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的「机皇」怪兽加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②的代价处理：从手卡丢弃1张卡作为发动代价。
function c39109382.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：手牌中是否存在至少1张可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际丢弃1张手卡（作为代价，计入丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②的目标选择：以自己场上1只怪兽为对象才能发动。
function c39109382.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 目标检测：自己场上是否存在至少1只可作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置将破坏1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏处理：将仍与效果关联的对象卡破坏（②③共用的处理）。
function c39109382.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前效果处理的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将那只对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③的触发条件过滤：被破坏的卡须是曾表侧表示存在于自己场上、原控制者为自己的「机皇」怪兽，且破坏原因是战斗或效果。
function c39109382.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousSetCard(0x13) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③的发动条件：本次被破坏的卡中存在满足上述条件的「机皇」怪兽。
function c39109382.descon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39109382.cfilter,1,nil,tp)
end
-- ③的目标过滤：场上表侧表示的魔法·陷阱卡（且不能是这张卡本身）。
function c39109382.desfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- ③的目标选择：以这张卡以外的场上1张表侧表示魔法·陷阱卡为对象才能发动。
function c39109382.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() and c39109382.desfilter2(chkc) end
	-- 目标检测：场上是否存在至少1张符合条件的表侧魔法·陷阱卡（且不是这张卡）。
	if chk==0 then return Duel.IsExistingTarget(c39109382.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 显示“选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示魔法·陷阱卡作为效果对象（不能选这张卡）。
	local g=Duel.SelectTarget(tp,c39109382.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置将破坏1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
