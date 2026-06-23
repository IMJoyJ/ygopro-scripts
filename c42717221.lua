--サイバース・クロック・ドラゴン
-- 效果：
-- 「时钟翼龙」＋连接怪兽1只以上
-- ①：这张卡的融合召唤成功时才能发动。把那些素材的连接标记合计数量的卡从自己卡组上面送去墓地。直到下个回合的结束时，其他的自己怪兽不能攻击，这张卡的攻击力上升这个效果送去墓地的数量×1000。
-- ②：只要自己场上有连接怪兽存在，对方不能把自己场上的其他怪兽作为攻击·效果的对象。
-- ③：融合召唤的这张卡被对方的效果送去墓地的场合才能发动。从卡组把1张魔法卡加入手卡。
function c42717221.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为21830679的「时钟翼龙」和1到127只连接怪兽作为融合素材
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
	-- ②：只要自己场上有连接怪兽存在，对方不能把自己场上的其他怪兽作为攻击·效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(c42717221.atcon)
	e2:SetValue(c42717221.atlimit)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有连接怪兽存在，对方不能把自己场上的其他怪兽作为攻击·效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c42717221.atcon)
	e3:SetTarget(c42717221.tglimit)
	-- 设置效果值为aux.tgoval函数，用于过滤不会成为对方的卡的效果对象
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
-- 判断此卡是否为融合召唤成功
function c42717221.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 计算融合素材中连接怪兽数量总和，并检查玩家是否可以将该数量的卡从卡组送去墓地
function c42717221.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=e:GetHandler():GetMaterial():Filter(Card.IsType,nil,TYPE_LINK)
	local ct=0
	-- 遍历融合素材中的连接怪兽
	for tc in aux.Next(mg) do
		ct=ct+tc:GetLink()
	end
	-- 检查是否满足发动条件：连接怪兽数量大于0且玩家可以将该数量的卡从卡组送去墓地
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	e:SetLabel(ct)
	-- 设置连锁操作信息，表示将要从卡组送去墓地的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 执行效果操作：将卡组顶部的卡送去墓地，并根据送去墓地的卡数量增加攻击力
function c42717221.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行将卡组顶部的卡送去墓地的操作
	if Duel.DiscardDeck(tp,e:GetLabel(),REASON_EFFECT)~=0 then
		-- 获取实际被送去墓地的卡数量
		local ct=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		-- 创建一个场上的效果，使其他怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c42717221.ftarget)
		e1:SetLabel(c:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
		if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 增加此卡的攻击力
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
			c:RegisterEffect(e1)
		end
	end
end
-- 判断目标怪兽是否为本卡
function c42717221.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 判断自己场上是否存在连接怪兽
function c42717221.atcon(e)
	-- 检查自己场上是否存在至少1只连接怪兽
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_LINK)
end
-- 判断目标怪兽是否为本卡
function c42717221.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 判断目标怪兽是否为本卡
function c42717221.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 判断此卡是否为融合召唤成功并被对方效果送入墓地
function c42717221.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤出卡组中可加入手牌的魔法卡
function c42717221.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将要从卡组检索一张魔法卡加入手牌
function c42717221.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42717221.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索一张魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作：从卡组检索一张魔法卡加入手牌
function c42717221.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中的一张魔法卡
	local g=Duel.SelectMatchingCard(tp,c42717221.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
