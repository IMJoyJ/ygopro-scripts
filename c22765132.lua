--EMコール
-- 效果：
-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效，守备力合计最多到作为对象的怪兽的攻击力以下为止，从卡组把最多2只「娱乐伙伴」怪兽加入手卡。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
function c22765132.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c22765132.condition)
	e1:SetTarget(c22765132.target)
	e1:SetOperation(c22765132.activate)
	c:RegisterEffect(e1)
end
-- 攻击怪兽控制权不属于发动玩家且没有攻击目标
function c22765132.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽控制权不属于发动玩家且没有攻击目标
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数，用于检索满足条件的「娱乐伙伴」怪兽
function c22765132.filter(c,def)
	return c:IsSetCard(0x9f) and c:IsDefenseBelow(def) and c:IsAbleToHand()
end
-- 设置效果目标为攻击怪兽，并检查卡组是否存在满足条件的「娱乐伙伴」怪兽
function c22765132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsOnField() and at:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在满足条件的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c22765132.filter,tp,LOCATION_DECK,0,1,nil,at:GetAttack()) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(at)
	-- 设置效果操作信息为检索「娱乐伙伴」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动，无效攻击并检索「娱乐伙伴」怪兽
function c22765132.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 无效此次攻击
	if Duel.NegateAttack() then
		local val=tc:GetAttack()
		-- 提示发动玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1只满足条件的「娱乐伙伴」怪兽
		local g1=Duel.SelectMatchingCard(tp,c22765132.filter,tp,LOCATION_DECK,0,1,1,nil,val)
		local sc=g1:GetFirst()
		if sc then
			val=val-sc:GetDefense()
			-- 检查是否还存在满足条件的「娱乐伙伴」怪兽
			if Duel.IsExistingMatchingCard(c22765132.filter,tp,LOCATION_DECK,0,1,sc,val)
				-- 询问发动玩家是否继续检索第2只「娱乐伙伴」怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(22765132,0)) then  --"把最多2只「娱乐伙伴」怪兽加入手卡"
				-- 提示发动玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 从卡组中选择第2只满足条件的「娱乐伙伴」怪兽
				local g2=Duel.SelectMatchingCard(tp,c22765132.filter,tp,LOCATION_DECK,0,1,1,sc,val)
				g1:Merge(g2)
			end
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			-- 向对手确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,g1)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c22765132.sumlimit)
		-- 判断当前回合玩家是否为发动玩家
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 注册不能特殊召唤效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤额外卡组的怪兽
function c22765132.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
