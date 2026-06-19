--豆まき
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。选那只怪兽的等级数量的自己手卡丢弃，自己从卡组抽出丢弃的数量。那之后，作为对象的怪兽回到持有者手卡。
function c83828288.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。选那只怪兽的等级数量的自己手卡丢弃，自己从卡组抽出丢弃的数量。那之后，作为对象的怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83828288.target)
	e1:SetOperation(c83828288.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的对方场上表侧表示怪兽的函数
function c83828288.filter(c,tp)
	local lv=c:GetLevel()
	-- 过滤条件：等级大于0、表侧表示、可以回到手卡、自己手卡数量大于等于该怪兽等级、且自己可以从卡组抽该等级数量的卡
	return lv>0 and c:IsFaceup() and c:IsAbleToHand() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=lv and Duel.IsPlayerCanDraw(tp,lv)
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象、设置操作信息）
function c83828288.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c83828288.filter(chkc,tp) end
	-- 检查对方场上是否存在满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c83828288.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1只满足条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83828288.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,lv)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,lv)
	-- 设置操作信息：将选中的对象怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的执行处理（丢弃手卡、抽卡、之后将对象怪兽送回手卡）
function c83828288.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	local lv=tc:GetLevel()
	-- 检查对象怪兽是否仍适应此效果，且自己手卡数量是否仍大于等于该怪兽的等级
	if tc:IsRelateToEffect(e) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=lv then
		-- 玩家选择并丢弃与该怪兽等级相同数量的自己手卡
		local ct=Duel.DiscardHand(tp,aux.TRUE,lv,lv,REASON_EFFECT+REASON_DISCARD)
		-- 如果成功丢弃手卡，则自己从卡组抽出与丢弃数量相同的卡
		if ct>0 and Duel.Draw(tp,lv,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续的“回到手卡”处理不与“丢弃并抽卡”同时进行
			Duel.BreakEffect()
			-- 将作为对象的怪兽送回持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
