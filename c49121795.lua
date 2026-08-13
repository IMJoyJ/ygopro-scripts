--重装甲列車アイアン・ヴォルフ
-- 效果：
-- 机械族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只机械族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从卡组把1只机械族·4星怪兽加入手卡。
function c49121795.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续，素材要求为机械族4星怪兽2只。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只机械族怪兽为对象才能发动。这个回合，那只怪兽以外的怪兽不能攻击，那只怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49121795,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49121795.dacon)
	e1:SetCost(c49121795.dacost)
	e1:SetTarget(c49121795.datg)
	e1:SetOperation(c49121795.daop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。从卡组把1只机械族·4星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49121795,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c49121795.thcon)
	e2:SetTarget(c49121795.thtg)
	e2:SetOperation(c49121795.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断：当前回合玩家能够进入战斗阶段。
function c49121795.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家能否进入战斗阶段，作为效果①的发动条件。
	return Duel.IsAbleToEnterBP()
end
-- 效果①的发动代价（COST）：从这张卡上取除1个超量素材，取除时需先确认有素材可除。
function c49121795.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对象的过滤条件：自己场上表侧表示的机械族怪兽，且未被赋予直接攻击效果。
function c49121795.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果①的取对象处理：从自己场上选择1只符合条件的机械族怪兽作为对象。
function c49121795.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c49121795.dafilter(chkc) end
	-- 发动时检查自己场上是否存在至少1只符合条件的机械族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49121795.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择表侧表示卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的机械族怪兽作为效果对象（该对象会被记录为连锁对象）。
	Duel.SelectTarget(tp,c49121795.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①处理时：给己方场上除对象怪兽以外的所有怪兽附加不能攻击效果；若对象仍相关，则给对象怪兽赋予直接攻击效果。
function c49121795.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 这个回合，那只怪兽以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c49121795.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对象以外怪兽不能攻击”的效果注册到己方场上，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽可以直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数：若怪兽的FieldID不是对象怪兽的FieldID，则受到不能攻击效果影响（即对象以外的怪兽不能攻击）。
function c49121795.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②的诱发条件：这张卡原本控制者为己方、被对方破坏并送去墓地。
function c49121795.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 效果②检索对象的过滤条件：机械族·4星怪兽且可以加入手卡。
function c49121795.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果②的发动时处理：检查卡组中是否有符合条件的机械族·4星怪兽，并设定检索回手牌的操作信息。
function c49121795.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在至少1张符合检索条件的机械族·4星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c49121795.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的处理信息：从卡组将1张卡加入手牌（CATEGORY_TOHAND），供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时：从卡组选择1只符合条件的机械族·4星怪兽加入手牌，并让对手确认。
function c49121795.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择要加入手牌的卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选取1张符合条件的机械族·4星怪兽。
	local g=Duel.SelectMatchingCard(tp,c49121795.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌（此处即己方手牌），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
