--ギガンティック“チャンピオン”サルガス
-- 效果：
-- 8星怪兽×2只以上
-- 「巨大喷流“冠军”尾宿五」1回合1次也能在自己场上的「护宝炮妖」超量怪兽上面重叠来超量召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡持有超量素材的场合才能发动。从卡组把1张「护宝炮妖」卡或者「兽带斗神」卡加入手卡。
-- ②：场上的超量素材被取除的场合，以场上1张卡为对象才能发动。那张卡破坏或回到手卡。
function c11132674.initial_effect(c)
	-- 启用全局的去除超量素材事件标记，使场上发生的去除超量素材行为能够触发EVENT_DETACH_MATERIAL事件，从而满足②效果的诱发条件。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	aux.AddXyzProcedure(c,nil,8,2,c11132674.ovfilter,aux.Stringid(11132674,0),99,c11132674.xyzop)  --"是否在「护宝炮妖」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡持有超量素材的场合才能发动。从卡组把1张「护宝炮妖」卡或者「兽带斗神」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11132674,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11132674)
	e1:SetCondition(c11132674.srcon)
	e1:SetTarget(c11132674.srtg)
	e1:SetOperation(c11132674.srop)
	c:RegisterEffect(e1)
	-- ②：场上的超量素材被取除的场合，以场上1张卡为对象才能发动。那张卡破坏或回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11132674,2))  --"场上1张卡破坏或回到持有者手卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11132675)
	e2:SetCondition(c11132674.descon)
	e2:SetTarget(c11132674.destg)
	e2:SetOperation(c11132674.desop)
	c:RegisterEffect(e2)
end
-- 超量召唤替代条件的过滤函数：用于判断自己场上是否存在表侧表示且为「护宝炮妖」（0x155）超量怪兽，从而允许这张卡直接重叠在该怪兽上方进行超量召唤。
function c11132674.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 自定义超量召唤手续的操作函数：用于实现「巨大喷流“冠军”尾宿五」1回合1次在自己场上的「护宝炮妖」超量怪兽上面重叠来超量召唤的限制；chk==0时检查是否已使用过该方式，否则注册誓约标记记录使用次数。
function c11132674.xyzop(e,tp,chk)
	-- 检查玩家tp是否已在本回合通过该方式超量召唤过：若不存在标志11132674则返回true，允许进行重叠超量召唤；若已存在则返回false，拒绝再次使用该方式。
	if chk==0 then return Duel.GetFlagEffect(tp,11132674)==0 end
	-- 为玩家注册一个回合结束阶段重置的誓约标志（EFFECT_FLAG_OATH），记录本回合已经使用过“在「护宝炮妖」超量怪兽上重叠”的超量召唤方式。
	Duel.RegisterFlagEffect(tp,11132674,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动条件判定：这张卡当前持有超量素材（OverlayCount>0）时才允许发动检索效果。
function c11132674.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
-- ①效果的检索过滤函数：选择卡组中字段为「护宝炮妖」（0x155）或「兽带斗神」（0x179）且能够加入手卡的卡。
function c11132674.srfilter(c)
	return c:IsSetCard(0x155,0x179) and c:IsAbleToHand()
end
-- ①效果的发动目标判断：检查自己卡组是否存在至少1张符合条件的卡；若存在则设置操作信息，表示本次连锁将进行从卡组把卡加入手卡的处理。
function c11132674.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若卡组中不存在1张满足检索条件的卡，则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c11132674.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为“从卡组把1张卡加入手卡”，供其他卡（如星尘龙等）或规则判定使用；此时尚未确定具体卡片，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：发动者从卡组选择1张「护宝炮妖」或「兽带斗神」卡加入手卡，并向对方展示选择的卡。
function c11132674.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示消息，提示发动者“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从发动者卡组中选择1张满足srfilter过滤条件的卡，范围限制为自己卡组（LOCATION_DECK、己方0张、对方0张），恰好选择1张。
	local g=Duel.SelectMatchingCard(tp,c11132674.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认，确保对方可见。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的诱发条件：场上的超量素材被取除时，若取除的素材中至少1张位于怪兽区，则满足“场上的超量素材被取除的场合”这一触发条件，且为场合型延迟效果。
function c11132674.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
end
-- ②效果的发动时点处理：以场上1张卡为对象（不限定表侧或里侧，也不限定怪兽/魔法/陷阱区），选择该对象并登记为当前连锁的目标。
function c11132674.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：场上是否存在至少1张可以成为效果对象的卡（aux.TRUE表示任意卡），如果不存在则②效果无法发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择对象提示消息，提示发动者“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方场上（LOCATION_ONFIELD）选择1张卡作为效果对象，并通过SelectTarget将其自动建立与当前连锁的关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果处理：取得对象卡，若对象卡仍与效果关联，则让发动者选择“破坏”或“回到手卡”；若选择回手且卡片可以加入手卡，则回手，否则执行破坏。
function c11132674.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中的第一张对象卡，即②效果选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsAbleToHand()
		-- 判断目标卡是否可以被送去手卡；如果可以，则弹出选项让发动者选择“破坏”（选项0）或“回到手卡”（选项1）；选择回手时条件为真，执行回手处理。
		and Duel.SelectOption(tp,aux.Stringid(11132674,3),aux.Stringid(11132674,4))==1 then  --"破坏/回到手卡"
		-- 将目标卡以效果原因送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		-- 将目标卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
