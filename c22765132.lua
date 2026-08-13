--EMコール
-- 效果：
-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效，守备力合计最多到作为对象的怪兽的攻击力以下为止，从卡组把最多2只「娱乐伙伴」怪兽加入手卡。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
function c22765132.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时，以那1只攻击怪兽为对象才能发动。那次攻击无效，守备力合计最多到作为对象的怪兽的攻击力以下为止，从卡组把最多2只「娱乐伙伴」怪兽加入手卡。
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
-- 发动条件函数：判断当前是否为对方怪兽的直接攻击宣言，只有满足该条件时效果才可发动。
function c22765132.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽由对方控制且没有攻击对象（即直接攻击宣言）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 卡组筛选条件：是「娱乐伙伴」怪兽、守备力不高于当前剩余攻击力上限、且可以加入手卡。
function c22765132.filter(c,def)
	return c:IsSetCard(0x9f) and c:IsDefenseBelow(def) and c:IsAbleToHand()
end
-- 发动时的目标选择和合法性检查：取得攻击怪兽，确认其在场且能成为效果对象，并确认卡组存在至少1只符合条件的「娱乐伙伴」怪兽。
function c22765132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取攻击宣言的怪兽，作为后续的对象候补和检索攻击力基准。
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsOnField() and at:IsCanBeEffectTarget(e)
		-- 确认卡组中存在至少1只「娱乐伙伴」怪兽，其守备力不超过攻击怪兽的攻击力，否则效果不能发动。
		and Duel.IsExistingMatchingCard(c22765132.filter,tp,LOCATION_DECK,0,1,nil,at:GetAttack()) end
	-- 将攻击怪兽设置为效果的对象（取对象）。
	Duel.SetTargetCard(at)
	-- 设置操作信息：本效果将把卡组的卡加入手卡，数量暂定1张，从自己的卡组检索，供其他效果连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：无效那次攻击；以攻击怪兽的攻击力为上限，从卡组选择1张符合条件的「娱乐伙伴」加入手卡，再询问是否选第2张，最后将所选卡加入手卡并展示给对手。
function c22765132.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象，即发动时指定的那只攻击怪兽。
	local tc=Duel.GetFirstTarget()
	-- 尝试无效那次攻击；只有无效成功后才继续执行检索加入手卡的处理。
	if Duel.NegateAttack() then
		local val=tc:GetAttack()
		-- 显示选择提示，提示玩家选择要加入手卡的「娱乐伙伴」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足条件（守备力不高于当前上限）的「娱乐伙伴」怪兽。
		local g1=Duel.SelectMatchingCard(tp,c22765132.filter,tp,LOCATION_DECK,0,1,1,nil,val)
		local sc=g1:GetFirst()
		if sc then
			val=val-sc:GetDefense()
			-- 检查在剩余守备力上限内，卡组中是否还有另一张符合条件的「娱乐伙伴」怪兽（排除已选的sc）。
			if Duel.IsExistingMatchingCard(c22765132.filter,tp,LOCATION_DECK,0,1,sc,val)
				-- 询问玩家是否将第二张「娱乐伙伴」也加入手卡，以实现“最多2只”的效果。
				and Duel.SelectYesNo(tp,aux.Stringid(22765132,0)) then  --"把最多2只「娱乐伙伴」怪兽加入手卡"
				-- 再次显示选择提示，用于选择第二张要加入手卡的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 选择第二张守备力不高于剩余攻击力上限的「娱乐伙伴」怪兽。
				local g2=Duel.SelectMatchingCard(tp,c22765132.filter,tp,LOCATION_DECK,0,1,1,sc,val)
				g1:Merge(g2)
			end
			-- 将选中的1张或2张卡加入持有者的手卡。
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
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
		-- 若当前回合玩家是自己，则自肃需要持续到下下次自己的结束阶段（跨越对方回合），因此重置计数设为2；否则持续到下次自己回合结束即可。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 为当前玩家注册“不能从额外卡组特殊召唤怪兽”的持续效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃判定函数：要特殊召唤的怪兽若位于额外卡组则不允许特殊召唤（即不能从额外卡组把怪兽特殊召唤）。
function c22765132.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
