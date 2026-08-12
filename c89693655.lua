--亜空間バトル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以下效果3次适用。
-- ●双方各自从自身卡组选1只攻击力?以外的怪兽，给双方确认。攻击力较高方的怪兽加入选那只的玩家手卡。攻击力较低方的怪兽破坏，选那只的玩家受到500伤害。攻击力相同的场合，选的怪兽回到卡组。这个回合，双方不能把这个效果让自身选的怪兽以及那些同名怪兽的怪兽效果发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以下效果3次适用。
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
-- 过滤卡组中攻击力不为?的怪兽卡
function s.dfilter(c)
	return c:GetTextAttack()>=0 and c:IsType(TYPE_MONSTER)
end
-- 效果发动的基本合法性检查（自己卡组存在符合条件的怪兽，且对方卡组存在卡片）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只攻击力?以外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
			-- 检查对方卡组是否存在至少1张卡片
			and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_DECK,1,nil) end
end
-- 效果处理的入口函数，首先再次确认双方卡组中是否存在符合条件的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组中是否仍存在攻击力?以外的怪兽
	if not (Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方卡组中是否仍存在攻击力?以外的怪兽，若任意一方不满足则结束处理
		and Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_DECK,1,nil)) then
		return
	end
	local res=true
	local ct=3
	while res and ct>0 do
		-- 在第二次和第三次适用效果前，插入时点中断，使前后处理不视为同时进行
		if ct~=3 then Duel.BreakEffect() end
		-- 提示自己选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 自己从卡组选择1只攻击力?以外的怪兽
		local g1=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 提示对方选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 对方从卡组选择1只攻击力?以外的怪兽
		local g2=Duel.SelectMatchingCard(1-tp,s.dfilter,1-tp,LOCATION_DECK,0,1,1,nil)
		-- 将自己选择的怪兽给对方确认
		Duel.ConfirmCards(1-tp,g1)
		-- 将对方选择的怪兽给自己确认
		Duel.ConfirmCards(tp,g2)
		local tc1=g1:GetFirst()
		local tc2=g2:GetFirst()
		-- 双方各自从自身卡组选1只攻击力?以外的怪兽，给双方确认。攻击力较高方的怪兽加入选那只的玩家手卡。攻击力较低方的怪兽破坏，选那只的玩家受到500伤害。攻击力相同的场合，选的怪兽回到卡组。这个回合，双方不能把这个效果让自身选的怪兽以及那些同名怪兽的怪兽效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc1:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制自己发动该怪兽及同名怪兽效果的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetTargetRange(0,1)
		e2:SetLabel(tc2:GetCode())
		-- 注册限制对方发动该怪兽及同名怪兽效果的全局效果
		Duel.RegisterEffect(e2,tp)
		if tc1:GetAttack()>tc2:GetAttack() then
			if tc1:IsAbleToHand() then
				-- 将自己选的怪兽加入自己手卡
				Duel.SendtoHand(tc1,nil,REASON_EFFECT)
				-- 向对方确认加入手卡的怪兽
				Duel.ConfirmCards(1-tp,tc1)
			else
				-- 若无法加入手卡，则根据规则将该怪兽送去墓地
				Duel.SendtoGrave(tc1,REASON_RULE)
			end
			-- 破坏对方选的怪兽
			Duel.Destroy(tc2,REASON_EFFECT)
			-- 给予对方500点伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		elseif tc1:GetAttack()<tc2:GetAttack() then
			if tc2:IsAbleToHand() then
				-- 将对方选的怪兽加入对方手卡
				Duel.SendtoHand(tc2,nil,REASON_EFFECT)
				-- 向自己确认加入手卡的怪兽
				Duel.ConfirmCards(tp,tc2)
			else
				-- 若无法加入手卡，则根据规则将该怪兽送去墓地
				Duel.SendtoGrave(tc2,REASON_RULE)
			end
			-- 破坏自己选的怪兽
			Duel.Destroy(tc1,REASON_EFFECT)
			-- 给予自己500点伤害
			Duel.Damage(tp,500,REASON_EFFECT)
		end
		-- 检查自己卡组是否还有符合条件的怪兽，以决定是否能继续下一次适用
		res=(Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil)
			-- 检查对方卡组是否还有符合条件的怪兽，以决定是否能继续下一次适用
			and Duel.IsExistingMatchingCard(s.dfilter,tp,0,LOCATION_DECK,1,nil))
		ct=ct-1
	end
	if ct~=3 then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 洗切对方的卡组
		Duel.ShuffleDeck(1-tp)
	end
end
-- 限制发动效果的过滤函数，匹配特定卡名且必须是怪兽效果
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
