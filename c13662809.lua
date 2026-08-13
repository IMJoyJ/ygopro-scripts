--魔界台本「魔王の降臨」
-- 效果：
-- ①：以最多有自己场上的攻击表示的「魔界剧团」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。自己场上有7星以上的「魔界剧团」怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」卡或者「魔界台本」魔法卡合计最多2张加入手卡（同名卡最多1张）。
function c13662809.initial_effect(c)
	-- ①：以最多有自己场上的攻击表示的「魔界剧团」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。自己场上有7星以上的「魔界剧团」怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13662809,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c13662809.target)
	e1:SetOperation(c13662809.activate)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组把「魔界剧团」卡或者「魔界台本」魔法卡合计最多2张加入手卡（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13662809,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c13662809.thcon)
	e2:SetTarget(c13662809.thtg)
	e2:SetOperation(c13662809.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为表侧攻击表示且属于「魔界剧团」系列怪兽，用于统计自己场上此类怪兽的种类数。
function c13662809.cfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x10ec)
end
-- 过滤函数：判断卡是否为表侧表示、7星以上且属于「魔界剧团」系列怪兽，用于检测是否满足对方不能对应发动的追加条件。
function c13662809.lmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsLevelAbove(7)
end
-- 效果①的发动处理入口：chkc时验证对象是场上表侧表示且不是本卡；chk==0时检查自己场上有表侧攻击表示的「魔界剧团」怪兽且场上存在其他表侧表示卡可作为对象。
function c13662809.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认自己场上有至少1只表侧攻击表示的「魔界剧团」怪兽，用于计算可选对象数量上限；否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13662809.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动合法性检查：确认场上存在至少1张除本卡以外的表侧表示卡可以作为对象；否则不能发动。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取自己场上所有表侧攻击表示的「魔界剧团」怪兽，用于计算不同卡名种类数量。
	local g=Duel.GetMatchingGroup(c13662809.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 弹出选择提示消息，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1至ct张场上的表侧表示卡作为对象（ct为「魔界剧团」怪兽种类数，且不能选择本卡），并登记为连锁对象。
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 登记此次连锁的破坏操作信息：对象为所选对象卡，数量为其张数，供后续效果检测和时点使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 若自己场上有表侧表示且7星以上的「魔界剧团」怪兽，且该效果为魔法卡的发动，则进入设置连锁限制的步骤。
	if Duel.IsExistingMatchingCard(c13662809.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 为当前连锁设置连锁限制函数chainlm：只允许效果发动者本身连锁，从而让对方不能对应这张卡的发动把效果发动。
		Duel.SetChainLimit(c13662809.chainlm)
	end
end
-- 效果①处理：取出连锁对象中仍与该效果相关的卡，并将它们全部以效果原因破坏。
function c13662809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取发动时选择的对象卡组，并过滤出仍然与该效果关联的卡（对象离场或失效则不会处理）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡以效果原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 连锁限制函数：仅当试图连锁的玩家与效果发动者为同一人时允许连锁；即对方不能连锁这张卡的发动。
function c13662809.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤函数：判断额外卡组中的卡是否为表侧表示的「魔界剧团」灵摆怪兽，用于确认②的发动条件。
function c13662809.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- ②的发动条件：本卡因对方的效果被破坏，且破坏前是里侧表示盖放在自己场上，并且自己的额外卡组存在表侧表示的「魔界剧团」灵摆怪兽。
function c13662809.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己的额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽，这是②效果发动的必要条件之一。
		and Duel.IsExistingMatchingCard(c13662809.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 检索过滤函数：卡属于「魔界剧团」卡，或属于「魔界台本」魔法卡，并且可以被加入手卡。
function c13662809.thfilter(c)
	return (c:IsSetCard(0x10ec) or (c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL))) and c:IsAbleToHand()
end
-- ②的发动条件检查与操作信息登记：若卡组存在符合条件的卡，则设置从卡组检索并加入手卡的操作信息。
function c13662809.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②发动条件检查：确认卡组中存在至少1张符合条件的「魔界剧团」卡或「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c13662809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次连锁将从卡组把卡片加入手卡，目标来源为卡组，预计处理数量为1张（实际处理时可最多2张），归属为发动者。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理：从卡组筛选所有符合条件的卡片，由玩家选择1~2张卡名互不相同的卡加入手卡，并向对方展示。
function c13662809.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的「魔界剧团」卡或「魔界台本」魔法卡的集合。
	local g=Duel.GetMatchingGroup(c13662809.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()<=0 then return end
	-- 弹出选择加入手卡卡的提示消息，提示内容为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从符合条件的卡中，选择1~2张卡名互不相同的卡（同名卡最多1张），返回所选卡组。
	local sg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 将选中的卡加入其持有者的手卡，原因记为效果。
	Duel.SendtoHand(sg1,nil,REASON_EFFECT)
	-- 将实际加入手卡的卡片展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg1)
end
