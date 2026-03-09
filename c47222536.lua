--黒の魔導陣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡确认。可以从那之中把1只「黑魔术师」或者1张有那个卡名记述的魔法·陷阱卡给对方观看并加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
-- ②：自己场上有「黑魔术师」召唤·特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c47222536.initial_effect(c)
	-- 记录此卡效果文本中记载着「黑魔术师」这张卡的卡名
	aux.AddCodeList(c,46986414)
	-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡确认。可以从那之中把1只「黑魔术师」或者1张有那个卡名记述的魔法·陷阱卡给对方观看并加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,47222536)
	e1:SetTarget(c47222536.target)
	e1:SetOperation(c47222536.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「黑魔术师」召唤·特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47222536,1))  --"对方场上1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,47222537)
	e2:SetCondition(c47222536.rmcon)
	e2:SetTarget(c47222536.rmtg)
	e2:SetOperation(c47222536.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果处理时确认卡组最上方3张卡是否满足条件
function c47222536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若卡组最上方不足3张则不执行效果
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- 定义过滤器函数，用于筛选符合条件的魔法·陷阱卡或黑魔术师
function c47222536.filter(c)
	-- 筛选条件：为黑魔术师或记载着黑魔术师的魔法·陷阱卡且能加入手牌
	return (aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(46986414)) and c:IsAbleToHand()
end
-- 发动时处理效果：确认卡组最上方3张卡并决定是否将其中一张加入手牌
function c47222536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组最上方不足3张则不执行效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 获取卡组最上方3张卡的集合
	local g=Duel.GetDecktopGroup(tp,3)
	-- 向玩家确认这3张卡
	Duel.ConfirmCards(tp,g)
	-- 判断是否有符合条件的卡且玩家选择将一张加入手牌
	if g:IsExists(c47222536.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(47222536,0)) then  --"是否把1张卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c47222536.filter,1,1,nil)
		-- 禁止后续操作自动洗切卡组
		Duel.DisableShuffleCheck()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
		-- 手动洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 将剩余2张卡按顺序放回卡组最上方
		Duel.SortDecktop(tp,tp,2)
	-- 若未选择加入手牌，则将3张卡按顺序放回卡组最上方
	else Duel.SortDecktop(tp,tp,3) end
end
-- 定义过滤器函数，用于判断是否为场上的黑魔术师
function c47222536.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(46986414) and c:IsControler(tp)
end
-- 判断是否有黑魔术师被召唤或特殊召唤成功
function c47222536.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47222536.cfilter,1,nil,tp)
end
-- 设置效果目标：选择对方场上一张可除外的卡
function c47222536.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在符合条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果：将目标卡除外
function c47222536.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
