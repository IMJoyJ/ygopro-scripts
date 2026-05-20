--黒蠍－棘のミーネ
-- 效果：
-- ①：这张卡给与对方战斗伤害时，可以从以下效果选择1个发动。
-- ●从卡组把1张「黑蝎」卡加入手卡。
-- ●以自己墓地1张「黑蝎」卡为对象才能发动。那张卡加入手卡。
function c74153887.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时，可以从以下效果选择1个发动。●从卡组把1张「黑蝎」卡加入手卡。●以自己墓地1张「黑蝎」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74153887,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c74153887.condition)
	e1:SetTarget(c74153887.target)
	e1:SetOperation(c74153887.operation)
	c:RegisterEffect(e1)
end
-- 判定此卡是否给与了对方玩家战斗伤害
function c74153887.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：卡名含有「黑蝎」且可以加入手牌的卡
function c74153887.filter(c)
	return c:IsSetCard(0x1a) and c:IsAbleToHand()
end
-- 效果发动时的对象合法性检查与可行性判定
function c74153887.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74153887.filter(chkc) end
	-- 可行性判定：检查卡组中是否存在可加入手牌的「黑蝎」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74153887.filter,tp,LOCATION_DECK,0,1,nil)
		-- 或者检查墓地中是否存在可作为对象并加入手牌的「黑蝎」卡
		or Duel.IsExistingTarget(c74153887.filter,tp,LOCATION_GRAVE,0,1,nil) end
	local op=0
	-- 如果卡组中存在可加入手牌的「黑蝎」卡
	if Duel.IsExistingMatchingCard(c74153887.filter,tp,LOCATION_DECK,0,1,nil)
		-- 并且墓地中也存在可加入手牌的「黑蝎」卡
		and Duel.IsExistingTarget(c74153887.filter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 让玩家在“卡组检索”和“墓地回收”中选择一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(74153887,1),aux.Stringid(74153887,2))  --"卡组检索/墓地回收"
	-- 否则，如果仅墓地中存在可加入手牌的「黑蝎」卡
	elseif Duel.IsExistingTarget(c74153887.filter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 强制选择“墓地回收”效果，并将操作标记设为1
		Duel.SelectOption(tp,aux.Stringid(74153887,2))  --"墓地回收"
		op=1
	else
		-- 否则（仅卡组中存在），强制选择“卡组检索”效果，并将操作标记设为0
		Duel.SelectOption(tp,aux.Stringid(74153887,1))  --"卡组检索"
		op=0
	end
	e:SetLabel(op)
	if op==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家选择墓地中1张「黑蝎」卡作为效果的对象
		local g=Duel.SelectTarget(tp,c74153887.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置效果处理信息：将选中的墓地卡片加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		-- 设置效果处理信息：从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:SetProperty(0)
	end
end
-- 效果处理的执行函数：根据玩家的选择，执行从墓地回收或从卡组检索的处理
function c74153887.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取在发动时选择的墓地目标卡片
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡片因效果加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「黑蝎」卡
		local g=Duel.SelectMatchingCard(tp,c74153887.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡片因效果加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
