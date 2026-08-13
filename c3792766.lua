--トリックスター・デビルフィニウム
-- 效果：
-- 「淘气仙星」怪兽2只以上
-- ①：这张卡所连接区有「淘气仙星」怪兽存在的场合，这张卡的攻击宣言时以最多有对方场上的连接怪兽数量的除外的自己的「淘气仙星」卡为对象才能发动。那些卡加入手卡。这张卡的攻击力直到回合结束时上升这个效果加入手卡的卡数量×1000。
function c3792766.initial_effect(c)
	-- 为这张卡添加连接召唤手续，需要以2只以上「淘气仙星」连接怪兽作为连接素材。
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
-- 此筛选函数用于判断所连接区的怪兽是否为表侧表示且属于「淘气仙星」系列。
function c3792766.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb)
end
-- 效果发动条件：这张卡所连接区存在表侧表示的「淘气仙星」怪兽。
function c3792766.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(c3792766.lkfilter,1,nil)
end
-- 此筛选函数用于选择对象：除外区中表侧表示、属于「淘气仙星」系列且可以被加入手卡的卡。
function c3792766.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- 效果的目标处理：确认存在符合条件的除外区「淘气仙星」卡和对方场上连接怪兽，然后选择1至ct张（ct为对方场上连接怪兽数量）作为效果对象，并设置将对象加入手牌的操作信息。
function c3792766.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c3792766.filter(chkc) end
	-- 发动合法性检查（chk==0）：确认自己除外区至少存在1张可作为对象的「淘气仙星」卡。
	if chk==0 then return Duel.IsExistingTarget(c3792766.filter,tp,LOCATION_REMOVED,0,1,nil)
		-- 发动合法性检查（chk==0）：确认对方场上存在连接怪兽，以决定可选对象数量上限（若无则不能发动）。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_LINK)	end
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 统计对方场上连接怪兽的数量，作为本次最多可选对象数。
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK)
	-- 从自己除外区选择1至ct张满足条件的「淘气仙星」卡作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,c3792766.filter,tp,LOCATION_REMOVED,0,1,ct,nil)
	-- 设置本次连锁的操作信息：效果处理时将这些对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将仍与效果关联的对象卡加入持有者手牌；若这张卡仍在场上且表侧表示，则根据实际加入手牌的卡数量，这张卡的攻击力直到回合结束时上升相应的数值。
function c3792766.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁记录的对象卡片组（即发动时选择的目标卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与该效果相关的对象卡送去持有者的手牌（效果处理）。
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取上一次卡片操作实际被移动的卡片组，用于统计实际加入手牌的卡数量。
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		if ct>0 then
			-- 这张卡的攻击力直到回合结束时上升这个效果加入手卡的卡数量×1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(ct*1000)
			c:RegisterEffect(e1)
		end
	end
end
