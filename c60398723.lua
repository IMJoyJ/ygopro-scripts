--森のざわめき
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽变成里侧守备表示。那之后，可以让场上存在的场地魔法卡回到持有者手卡。
function c60398723.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只怪兽变成里侧守备表示。那之后，可以让场上存在的场地魔法卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c60398723.target)
	e1:SetOperation(c60398723.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上表侧表示且可以变成里侧守备表示的怪兽
function c60398723.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动时的对象选择与处理：检查并选择对方场上1只表侧表示的怪兽作为效果对象
function c60398723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c60398723.filter(chkc) end
	-- 在发动时，检查对方场上是否存在至少1只可以变成里侧守备表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c60398723.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60398723.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明此效果包含改变表示形式的操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 过滤可以回到手牌的卡片
function c60398723.rfilter(c)
	return c:IsAbleToHand()
end
-- 效果处理：将选择的怪兽变成里侧守备表示，之后可选择让场上的场地魔法卡回到持有者手牌
function c60398723.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup()
		-- 将该怪兽变成里侧守备表示，并确认是否成功改变表示形式
		and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		-- 获取双方场地区域所有可以回到手牌的卡片（场地魔法）
		local rg=Duel.GetMatchingGroup(c60398723.rfilter,tp,LOCATION_FZONE,LOCATION_FZONE,nil)
		-- 若场上存在场地魔法，则询问玩家是否让其回到手牌
		if rg:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(60398723,0)) then  --"是否要让场地魔法返回手牌？"
			-- 中断效果处理，使前后的处理不视为同时进行
			Duel.BreakEffect()
			-- 将场上的场地魔法卡送回持有者的手牌
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end
