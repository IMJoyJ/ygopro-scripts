--トリックスター・デビルフィニウム
-- 效果：
-- 「淘气仙星」怪兽2只以上
-- ①：这张卡所连接区有「淘气仙星」怪兽存在的场合，这张卡的攻击宣言时以最多有对方场上的连接怪兽数量的除外的自己的「淘气仙星」卡为对象才能发动。那些卡加入手卡。这张卡的攻击力直到回合结束时上升这个效果加入手卡的卡数量×1000。
function c3792766.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2个连接素材，且连接素材必须是「淘气仙星」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区有「淘气仙星」怪兽存在的场合，这张卡的攻击宣言时以最多有对方场上的连接怪兽数量的除外的自己的「淘气仙星」卡为对象才能发动。那些卡加入手卡。这张卡的攻击力直到回合结束时上升这个效果加入手卡的卡数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c3792766.thcon)
	e1:SetTarget(c3792766.thtg)
	e1:SetOperation(c3792766.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为「淘气仙星」且正面表示
function c3792766.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb)
end
-- 效果发动条件，判断这张卡的连接区是否存在「淘气仙星」怪兽
function c3792766.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(c3792766.lkfilter,1,nil)
end
-- 过滤函数，用于判断目标卡是否为「淘气仙星」怪兽且可以加入手牌
function c3792766.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- 设置效果发动时的检索条件，检查自己除外区是否存在「淘气仙星」怪兽，并确认对方场上是否存在连接怪兽
function c3792766.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c3792766.filter(chkc) end
	-- 检查是否满足效果发动条件，即自己除外区存在「淘气仙星」怪兽且对方场上存在连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c3792766.filter,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查对方场上是否存在连接怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_LINK)	end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 计算对方场上的连接怪兽数量，作为最多可选择的除外「淘气仙星」怪兽数量
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK)
	-- 选择最多对方场上的连接怪兽数量的除外「淘气仙星」怪兽加入手牌
	local g=Duel.SelectTarget(tp,c3792766.filter,tp,LOCATION_REMOVED,0,1,ct,nil)
	-- 设置效果处理信息，将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数，将选择的卡加入手牌并根据加入手牌的数量提升攻击力
function c3792766.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡加入手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取实际被操作的卡组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		if ct>0 then
			-- 这张卡的攻击力直到回合结束时上升这个效果加入手卡的卡数量×1000
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(ct*1000)
			c:RegisterEffect(e1)
		end
	end
end
