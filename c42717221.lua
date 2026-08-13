--サイバース・クロック・ドラゴン
-- 效果：
-- 「时钟翼龙」＋连接怪兽1只以上
-- ①：这张卡的融合召唤成功时才能发动。把那些素材的连接标记合计数量的卡从自己卡组上面送去墓地。直到下个回合的结束时，其他的自己怪兽不能攻击，这张卡的攻击力上升这个效果送去墓地的数量×1000。
-- ②：只要自己场上有连接怪兽存在，对方不能把自己场上的其他怪兽作为攻击·效果的对象。
-- ③：融合召唤的这张卡被对方的效果送去墓地的场合才能发动。从卡组把1张魔法卡加入手卡。
function c42717221.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡号21830679（时钟翼龙）和1只以上连接怪兽为融合素材。
	aux.AddFusionProcCodeFunRep(c,21830679,aux.FilterBoolFunction(Card.IsFusionType,TYPE_LINK),1,127,true,true)
	-- ①：这张卡的融合召唤成功时才能发动。把那些素材的连接标记合计数量的卡从自己卡组上面送去墓地。直到下个回合的结束时，其他的自己怪兽不能攻击，这张卡的攻击力上升这个效果送去墓地的数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42717221,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c42717221.atkcon)
	e1:SetTarget(c42717221.atktg)
	e1:SetOperation(c42717221.atkop)
	c:RegisterEffect(e1)
	-- 对方不能把自己场上的其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(c42717221.atcon)
	e2:SetValue(c42717221.atlimit)
	c:RegisterEffect(e2)
	-- 对方不能把自己场上的其他怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c42717221.atcon)
	e3:SetTarget(c42717221.tglimit)
	-- 设定保护效果对效果对象的判定：只有对方发动的效果不能以我方这些怪兽为对象（即免疫对方效果对象）。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：融合召唤的这张卡被对方的效果送去墓地的场合才能发动。从卡组把1张魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42717221,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c42717221.thcon)
	e4:SetTarget(c42717221.thtg)
	e4:SetOperation(c42717221.thop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：这张卡以融合召唤方式特殊召唤成功。
function c42717221.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的发动时处理：统计融合素材中连接怪兽的连接标记合计数量，并检查能否从卡组顶将等量卡送去墓地；若可行则保存该数量并设置操作信息。
function c42717221.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetMaterial():Filter(Card.IsType,nil,TYPE_LINK)
	local ct=0
	-- 遍历融合素材中的连接怪兽，累加各连接怪兽的连接标记数量。
	for tc in aux.Next(mg) do
		ct=ct+tc:GetLink()
	end
	-- 发动合法性检查：连接标记合计大于0，且当前玩家可以将卡组顶对应数量的卡送去墓地。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	e:SetLabel(ct)
	-- 设置操作信息：本次效果处理中会将卡组顶ct张卡送去墓地（CATEGORY_DECKDES）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- ①效果处理：将卡组顶对应数量的卡送去墓地；若实际送入墓地数量不为0，则给己方其他怪兽附加不能攻击效果，并让这张卡攻击力上升送入墓地数量×1000。
function c42717221.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行从卡组顶丢弃e:GetLabel()张卡的操作，若实际送入墓地数量不为0则继续后续处理。
	if Duel.DiscardDeck(tp,e:GetLabel(),REASON_EFFECT)~=0 then
		-- 统计本次因效果操作而实际进入墓地的卡数量，作为攻击力上升的数值。
		local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		-- 直到下个回合的结束时，其他的自己怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c42717221.ftarget)
		e1:SetLabel(c:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能攻击效果注册到当前玩家的场上，持续到下个回合结束阶段。
		Duel.RegisterEffect(e1,tp)
		if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力上升这个效果送去墓地的数量×1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end
-- 不能攻击效果的过滤条件：使本卡以外的己方怪兽不能攻击（即排除本卡自身）。
function c42717221.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- ②效果的发动条件：自己场上有连接怪兽存在。
function c42717221.atcon(e)
	-- 检查自己场上是否存在至少1只连接怪兽。
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_LINK)
end
-- 攻击对象限制的判定：除本卡以外的怪兽不能被对方选择为攻击对象（值为真时禁止选择）。
function c42717221.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果对象限制的判定：除本卡以外的怪兽不能被对方选择为效果对象（值为真时禁止选择）。
function c42717221.tglimit(e,c)
	return c~=e:GetHandler()
end
-- ③效果的发动条件：这张卡是融合召唤的怪兽，并且被对方发动的效果从自己怪兽区送去墓地。
function c42717221.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索过滤条件：选择卡组中1张魔法卡，且该卡能够加入手牌。
function c42717221.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③效果的发动时处理：检查卡组是否存在符合条件的魔法卡，并设置操作信息为从卡组检索1张魔法卡加入手牌。
function c42717221.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1张符合条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c42717221.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理中会将卡组1张魔法卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张魔法卡加入手牌，并向对手展示确认。
function c42717221.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，要求玩家选择1张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的魔法卡（选择1张）。
	local g=Duel.SelectMatchingCard(tp,c42717221.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择到的魔法卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手确认（确认卡名等）。
		Duel.ConfirmCards(1-tp,g)
	end
end
