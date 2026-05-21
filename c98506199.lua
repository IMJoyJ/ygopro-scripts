--ウィンドペガサス＠イグニスター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选最多有自己场上的「@火灵天星」怪兽数量的对方场上的魔法·陷阱卡破坏。
-- ②：这张卡在场上·墓地存在的状态，这张卡以外的自己场上的卡被战斗或者对方的效果破坏的场合，把这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
function c98506199.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(),1)
	-- ①：自己主要阶段才能发动。选最多有自己场上的「@火灵天星」怪兽数量的对方场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98506199,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,98506199)
	e1:SetTarget(c98506199.destg)
	e1:SetOperation(c98506199.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡在场上·墓地存在的状态，这张卡以外的自己场上的卡被战斗或者对方的效果破坏的场合，把这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98506199,1))  --"对方卡回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,98506200)
	e2:SetCondition(c98506199.tdcon)
	-- 设置发动Cost为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c98506199.tdtg)
	e2:SetOperation(c98506199.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「@火灵天星」怪兽
function c98506199.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 效果①的发动准备与可行性检测
function c98506199.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98506199.ctfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且对方场上存在至少1张魔法·陷阱卡
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息为：破坏对方场上的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：选择并破坏对方场上的魔法·陷阱卡
function c98506199.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的「@火灵天星」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c98506199.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if ct>0 and g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,1,ct,nil)
		-- 显式示出被选择的卡片
		Duel.HintSelection(dg)
		-- 因效果破坏选中的卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
-- 过滤条件：原本由自己控制且在场上的卡，因战斗或对方的效果被破坏
function c98506199.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果②的发动条件：此卡以外的自己场上的卡被战斗或对方的效果破坏
function c98506199.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c98506199.cfilter,1,nil,tp)
end
-- 效果②的发动准备与取对象处理
function c98506199.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张可以回到卡组的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为：将目标卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理：将作为对象的卡送回持有者卡组
function c98506199.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
