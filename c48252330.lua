--マドルチェ・バトラスク
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡召唤成功时，场上有这张卡以外的名字带有「魔偶甜点」的怪兽存在的场合，可以从卡组把1张场地魔法卡加入手卡。
function c48252330.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48252330,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c48252330.retcon)
	e1:SetTarget(c48252330.rettg)
	e1:SetOperation(c48252330.retop)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，场上有这张卡以外的名字带有「魔偶甜点」的怪兽存在的场合，可以从卡组把1张场地魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48252330,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c48252330.shcon)
	e2:SetTarget(c48252330.shtg)
	e2:SetOperation(c48252330.shop)
	c:RegisterEffect(e2)
end
-- 判断效果发动条件：这张卡是因对方玩家的效果被破坏并送去墓地，且其上一个控制者是己方，即对应‘被对方破坏送去墓地’的判定。
function c48252330.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动目标处理：chk==0时直接返回true表示可发动，并设定将这张卡返回卡组的操作信息。
function c48252330.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明此效果将把这张卡返回持有者卡组，供连锁判定等机制参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果存在关联，则将其返回持有者卡组并洗牌。
function c48252330.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡返回持有者卡组，SEQ_DECKSHUFFLE表示返回后洗切卡组。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 定义筛选条件：表侧表示且卡名属于「魔偶甜点」系列（串联设定为0x71）。
function c48252330.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 判断召唤成功时的发动条件：场上是否存在至少1张这张卡以外的表侧表示的名字带有「魔偶甜点」的怪兽。
function c48252330.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 在双方怪兽区域中检索是否存在至少1张符合条件的除自身以外的「魔偶甜点」怪兽，作为效果能否发动的条件。
	return Duel.IsExistingMatchingCard(c48252330.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 定义可检索卡的条件：是场地魔法卡，且能够加入手卡。
function c48252330.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果的发动检查和目标设定：先确认卡组存在符合条件的场地魔法卡，再设置从卡组检索1张加入手卡的操作信息。
function c48252330.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，确认卡组中是否有至少1张符合条件的场地魔法卡，有此卡才能发动检索效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c48252330.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表明此效果会将1张卡从卡组加入手卡，用于连锁响应和效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：再次确认场上仍有其他「魔偶甜点」怪兽，然后让玩家从卡组选择1张场地魔法卡加入手卡，并展示给对方。
function c48252330.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前重确认发动条件是否仍然满足：场上仍有其他「魔偶甜点」怪兽，否则不处理。
	if not Duel.IsExistingMatchingCard(c48252330.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) then return end
	-- 向当前玩家发送选择提示，提示内容为“请选择要加入手牌的卡”，用于卡组选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中筛选符合条件的卡片，选择1张场地魔法卡。
	local g=Duel.SelectMatchingCard(tp,c48252330.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
