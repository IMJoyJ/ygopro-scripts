--撲滅の使徒
-- 效果：
-- 盖放的1张魔法或者陷阱卡破坏并且从游戏中除外。陷阱卡的场合把双方卡组确认，和破坏陷阱卡同名卡全部从游戏除外。
function c17449108.initial_effect(c)
	-- 创建效果对象并设置其分类为破坏和除外，类型为魔陷发动，具有取对象属性，时点为自由时点，目标函数为c17449108.target，发动函数为c17449108.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17449108.target)
	e1:SetOperation(c17449108.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标卡是否为盖放且可除外
function c17449108.filter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
-- 效果处理的目标选择函数，用于选择盖放的魔法或陷阱卡作为目标
function c17449108.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c17449108.filter(chkc) end
	-- 判断是否满足发动条件，即场上是否存在盖放的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c17449108.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的盖放魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c17449108.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要除外目标卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果发动时的处理函数，用于执行破坏和除外效果
function c17449108.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏并除外
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
		if tc:IsType(TYPE_TRAP) then
			local code=tc:GetCode()
			-- 获取双方卡组中与目标卡同名的卡
			local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,LOCATION_DECK,nil,code)
			-- 将符合条件的卡从游戏中除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			-- 获取己方卡组中所有卡
			g=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
			-- 确认己方卡组中的卡
			Duel.ConfirmCards(tp,g)
			-- 获取对方卡组中所有卡
			g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
			-- 确认对方卡组中的卡
			Duel.ConfirmCards(1-tp,g)
			-- 洗切己方卡组
			Duel.ShuffleDeck(tp)
			-- 洗切对方卡组
			Duel.ShuffleDeck(1-tp)
		end
	end
end
