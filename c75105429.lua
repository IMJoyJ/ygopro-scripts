--シンクロ・イジェクション
-- 效果：
-- 选择对方场上表侧表示存在的1只同调怪兽从游戏中除外，对方从卡组抽1张卡。
function c75105429.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只同调怪兽从游戏中除外，对方从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c75105429.target)
	e1:SetOperation(c75105429.operation)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示、可以被除外的同调怪兽
function c75105429.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择与合法性检测，包含对历史选择对象的有效性验证以及发动条件的判断
function c75105429.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c75105429.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在可以作为除外对象的表侧表示同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c75105429.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查对方玩家是否可以从卡组抽1张卡
		and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上表侧表示存在的1只同调怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c75105429.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该连锁包含将选中的怪兽除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置效果处理信息，表示该连锁包含对方玩家抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 效果处理的执行函数，将选中的对象怪兽除外，若除外成功则让对方抽1张卡
function c75105429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与效果相关且呈表侧表示，并将其除外，确认是否成功除外
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(tc,0,REASON_EFFECT)~=0 then
		-- 让对方玩家从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
