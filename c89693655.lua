--亜空間バトル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以下效果3次适用。
-- ●双方各自从自身卡组选1只攻击力?以外的怪兽，给双方确认。攻击力较高方的怪兽加入选那只的玩家手卡。攻击力较低方的怪兽破坏，选那只的玩家受到500伤害。攻击力相同的场合，选的怪兽回到卡组。这个回合，双方不能把这个效果让自身选的怪兽以及那些同名怪兽的怪兽效果发动。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以下效果3次适用。●双方各自从自身卡组选1只攻击力?以外的怪兽，给双方确认。攻击力较高方的怪兽加入选那只的玩家手卡。攻击力较低方的怪兽破坏，选那只的玩家受到500伤害。攻击力相同的场合，选的怪兽回到卡组。这个回合，双方不能把这个效果让自身选的怪兽以及那些同名怪兽的怪兽效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：攻击力非?的怪兽
function s.dfilter(c)
	return c:GetTextAttack()>=0 and c:IsType(TYPE_MONSTER)
end
-- 发动条件与操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有攻击力非?的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
			-- 且对方卡组存在卡片
			and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_DECK,1,nil) end
end
-- 效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组是否有攻击力非?的怪兽
	if not (Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
		-- 且对方卡组是否有攻击力非?的怪兽
		and Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_DECK,1,nil)) then
		return
	end
	local res=true
	local ct=3
	while res and ct>0 do
		-- 多次处理时中断效果
		if ct~=3 then Duel.BreakEffect() end
		-- 提示自己选择给对方确认的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 自己从卡组选择1只攻击力非?的怪兽
		local g1=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 提示对方选择给对方确认的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 对方从卡组选择1只攻击力非?的怪兽
		local g2=Duel.SelectMatchingCard(1-tp,s.dfilter,1-tp,LOCATION_DECK,0,1,1,nil)
		-- 向对方确认自己选的怪兽
		Duel.ConfirmCards(1-tp,g1)
		-- 向自己确认对方选的怪兽
		Duel.ConfirmCards(tp,g2)
		local tc1=g1:GetFirst()
		local tc2=g2:GetFirst()
		-- 攻击力较高方的怪兽加入选那只的玩家手卡。攻击力较低方的怪兽破坏，选那只的玩家受到500伤害。攻击力相同的场合，选的怪兽回到卡组。这个回合，双方不能把这个效果让自身选的怪兽以及那些同名怪兽的怪兽效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc1:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 封锁自己选的怪兽及其同名怪兽的效果发动
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetTargetRange(0,1)
		e2:SetLabel(tc2:GetCode())
		-- 封锁对方选的怪兽及其同名怪兽的效果发动
		Duel.RegisterEffect(e2,tp)
		if tc1:GetAttack()>tc2:GetAttack() then
			if tc1:IsAbleToHand() then
				-- 将攻击力较高的怪兽加入自己手卡
				Duel.SendtoHand(tc1,nil,REASON_EFFECT)
				-- 向对方确认加入手卡的怪兽
				Duel.ConfirmCards(1-tp,tc1)
			else
				-- 不能加入手卡时规则送去墓地
				Duel.SendtoGrave(tc1,REASON_RULE)
			end
			-- 破坏对方攻击力较低的怪兽
			Duel.Destroy(tc2,REASON_EFFECT)
			-- 给与对方500伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		elseif tc1:GetAttack()<tc2:GetAttack() then
			if tc2:IsAbleToHand(1-tp) then
				-- 将攻击力较高的怪兽加入对方手卡
				Duel.SendtoHand(tc2,nil,REASON_EFFECT,1-tp)
				-- 向自己确认对方加入手卡的怪兽
				Duel.ConfirmCards(tp,tc2)
			else
				-- 不能加入手卡时规则送去墓地
				Duel.SendtoGrave(tc2,REASON_RULE)
			end
			-- 破坏自己攻击力较低的怪兽
			Duel.Destroy(tc1,REASON_EFFECT)
			-- 受到500伤害
			Duel.Damage(tp,500,REASON_EFFECT)
		end
		-- 检查自己卡组是否仍有攻击力非?的怪兽
		res=(Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
			-- 且对方卡组是否仍有攻击力非?的怪兽
			and Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_DECK,1,nil))
		ct=ct-1
	end
	if ct~=3 then
		-- 洗切自己卡组
		Duel.ShuffleDeck(tp)
		-- 洗切对方卡组
		Duel.ShuffleDeck(1-tp)
	end
end
-- 怪兽效果发动限制条件
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
