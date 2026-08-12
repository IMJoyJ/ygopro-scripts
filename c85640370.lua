--舌先減少
-- 效果：
-- ①：对方把宣言1个卡名发动的效果发动时才能发动。那个效果无效。那之后，自己可以把宣言的1张卡从卡组加入手卡。
-- ②：盖放的这张卡被对方的效果破坏的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
local s,id,o=GetID()
-- 注册卡片效果：①效果（无效宣言卡名的效果并检索该卡）与②效果（被破坏时降低对方怪兽攻击力）
function s.initial_effect(c)
	-- ①：对方把宣言1个卡名发动的效果发动时才能发动。那个效果无效。那之后，自己可以把宣言的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力降低"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：对方发动了包含宣言卡名操作的效果，且该连锁可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中是否存在宣言卡名的操作信息
	local ex=Duel.GetOperationInfo(ev,CATEGORY_ANNOUNCE)
	-- 判断是否为对方发动的效果、是否存在宣言操作，且该效果可以被无效
	return rp==1-tp and ex and Duel.IsChainDisablable(ev)
end
-- ①效果的发动准备：设置无效效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使该效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 过滤条件：卡组中与宣言卡名相同且可以加入手牌的卡
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- ①效果的处理：使效果无效，并可选地将宣言的卡从卡组加入手牌
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方效果发动时宣言的卡名（参数值）
	local code=Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
	-- 尝试使该效果无效，若成功则继续处理
	if Duel.NegateEffect(ev)
		-- 检查自己卡组是否存在与宣言卡名相同的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,code)
		-- 询问玩家是否选择将该卡加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张与宣言卡名相同的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的加入手牌处理不与无效处理同时进行
			Duel.BreakEffect()
			-- 将选择的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的发动条件：自己场上盖放的这张卡因对方的效果被破坏并送去墓地或除外等场合
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果的对象选择：选择对方场上1只表侧表示怪兽为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果的处理：使作为对象的怪兽攻击力下降500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) then
		-- 那只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
