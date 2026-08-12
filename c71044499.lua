--抹殺の使徒
-- 效果：
-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽破坏并除外。除外的怪兽是反转怪兽的场合，再让双方把双方卡组确认，从那之中由自己把除外的怪兽的同名怪兽全部除外。
function c71044499.initial_effect(c)
	-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽破坏并除外。除外的怪兽是反转怪兽的场合，再让双方把双方卡组确认，从那之中由自己把除外的怪兽的同名怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c71044499.target)
	e1:SetOperation(c71044499.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤场上里侧表示且可以被除外的怪兽
function c71044499.filter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果①的发动准备（检查发动条件、选择对象并设置操作信息）
function c71044499.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71044499.filter(chkc) end
	-- 检查场上是否存在可以作为对象的里侧表示且能除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c71044499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动效果的玩家选择1只符合过滤条件的里侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c71044499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏操作的信息，表示将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置除外操作的信息，表示将除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的效果处理（破坏并除外对象怪兽，若为反转怪兽则确认双方卡组并除外同名卡）
function c71044499.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e)
		-- 将对象怪兽破坏并送去除外区，并判断是否成功破坏
		and Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)>0
		and tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_FLIP) then
		local code=tc:GetCode()
		-- 获取双方卡组中与被除外怪兽同名的所有卡片
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,LOCATION_DECK,nil,code)
		-- 将获取到的同名卡全部表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		-- 获取对方卡组的所有卡片
		g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
		-- 让己方玩家确认对方的卡组
		Duel.ConfirmCards(tp,g)
		-- 获取己方卡组的所有卡片
		g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		-- 让对方玩家确认己方的卡组
		Duel.ConfirmCards(1-tp,g)
		-- 洗切己方玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 洗切对方玩家的卡组
		Duel.ShuffleDeck(1-tp)
	end
end
