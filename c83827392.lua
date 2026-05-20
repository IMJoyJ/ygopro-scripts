--エクスピュアリィ・ノアール
-- 效果：
-- 7星怪兽×2
-- 这张卡也能在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤。
-- ①：持有超量素材5个以上的这张卡不受对方发动的效果影响。
-- ②：把这张卡2个超量素材取除，以对方的场上·墓地1张卡为对象才能发动。那张卡回到持有者卡组最下面。这张卡有1星「纯爱妖精」怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包括XYZ召唤手续、不受影响的永续效果、自己回合发动的起动效果以及在特定条件下在对方回合也能发动的诱发即时效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0))  --"是否在持有超量素材5个以上的自己的2阶怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：持有超量素材5个以上的这张卡不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imecon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除，以对方的场上·墓地1张卡为对象才能发动。那张卡回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"对方卡回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tdcon1)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.tdcon2)
	c:RegisterEffect(e3)
end
-- 过滤用于重叠超量召唤的怪兽，必须是表侧表示、2阶的超量怪兽且持有5个以上的超量素材。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(2) and c:GetOverlayCount()>=5
end
-- 免疫效果的判定条件：自身持有的超量素材在5个以上。
function s.imecon(e)
	return e:GetHandler():GetOverlayCount()>=5
end
-- 免疫效果的过滤条件：不受对方玩家拥有的、且是发动的效果的影响。
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 检查超量素材中是否存在1星的「纯爱妖精」怪兽。
function s.check(c)
	return c:IsSetCard(0x18c) and c:IsLevel(1)
end
-- 起动效果的发动条件：超量素材中不存在1星「纯爱妖精」怪兽（只能在自己回合发动）。
function s.tdcon1(e)
	return not e:GetHandler():GetOverlayGroup():IsExists(s.check,1,nil)
end
-- 诱发即时效果的发动条件：超量素材中存在1星「纯爱妖精」怪兽（在对方回合也能发动）。
function s.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(s.check,1,nil)
end
-- 效果发动的代价：取除自身的2个超量素材。
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	-- 给玩家发送提示信息，要求选择要取除的超量素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果发动的目标选择与判定：以对方场上或墓地的一张可以回到卡组的卡为对象。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 判定对方场上或墓地是否存在至少1张可以回到卡组的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 向对方玩家提示本效果已被选择发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给玩家发送提示信息，要求选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 优先从场上（其次从墓地）选择1张对方的卡作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果会将选中的1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将作为对象的卡片回到持有者卡组最下面。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果处理的方式送回持有者卡组的最下方。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
