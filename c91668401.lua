--サイバー・エンジェル－伊舎那－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1张魔法·陷阱卡送去墓地。
-- ②：这张卡的攻击破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
-- ③：1回合1次，自己场上的「电子化天使」仪式怪兽为对象的对方的效果发动时才能发动。选自己墓地1只仪式怪兽回到卡组，选对方场上1张卡破坏。
function c91668401.initial_effect(c)
	-- 将「机械天使的仪式」注册为本卡片记载的卡名
	aux.AddCodeList(c,39996157)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1张魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91668401,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c91668401.tgcon)
	e1:SetTarget(c91668401.tgtg)
	e1:SetOperation(c91668401.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c91668401.atcon)
	e2:SetOperation(c91668401.atop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己场上的「电子化天使」仪式怪兽为对象的对方的效果发动时才能发动。选自己墓地1只仪式怪兽回到卡组，选对方场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91668401,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c91668401.descon)
	e3:SetTarget(c91668401.destg)
	e3:SetOperation(c91668401.desop)
	c:RegisterEffect(e3)
end
-- 检查是否为仪式召唤成功
function c91668401.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果发动判定：检查对方魔陷区是否有卡片存在，并设定操作信息
function c91668401.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上魔法·陷阱区是否有卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0 end
	-- 设置送去墓地的操作信息，包含1张对方魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_SZONE)
end
-- 效果处理：对方玩家必须选择自身魔陷区1张卡送去墓地
function c91668401.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_SZONE,0,nil)
	if #g>0 then
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 手动为所选的卡片显示被选中的特效
		Duel.HintSelection(sg)
		-- 对方玩家自身将所选卡片送去墓地（此处理为规则强迫操作，可绕过抗性）
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 检查是否满足连续攻击的条件（必须是此卡进行攻击、战斗破坏怪兽送墓、且可以连续攻击）
function c91668401.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断此卡是否是攻击怪兽、是否处于战斗中、能继续攻击且对方被破坏的怪兽在墓地
	return c==Duel.GetAttacker() and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and c:IsChainAttackable(2,true)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果处理：使此卡能再进行1次攻击且该回合无法直接攻击
function c91668401.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 使攻击怪兽可以再进行1次攻击
		Duel.ChainAttack()
		-- 这张卡只再1次可以继续向对方怪兽攻击（本回合内不能直接攻击）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：检查是否是自己场上的「电子化天使」仪式怪兽
function c91668401.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x2093) and c:IsType(TYPE_RITUAL)
end
-- 检查对方的效果发动时是否以自己场上的「电子化天使」仪式怪兽为对象
function c91668401.descon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取对方效果所针对的所有对象卡片
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c91668401.cfilter,1,nil,tp)
end
-- 过滤函数：检查是否为自己墓地中能回到卡组的仪式怪兽
function c91668401.tdfilter(c)
	return c:GetType()&0x81==0x81 and c:IsAbleToDeck()
end
-- 效果发动判定：检查自己墓地是否有仪式怪兽且对方场上是否存在卡片，并设定操作信息
function c91668401.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在能够返回卡组的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91668401.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在可以被破坏的卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置将自己墓地怪兽返回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置破坏对方场上卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：选自己墓地1只仪式怪兽回到卡组，成功后选对方场上1张卡破坏
function c91668401.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只仪式怪兽作为效果处理对象
	local g=Duel.SelectMatchingCard(tp,c91668401.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 手动为所选返回卡组的怪兽显示选择动画
		Duel.HintSelection(g)
		-- 将所选仪式怪兽送回持有者卡组并洗牌，判断是否成功
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方场上1张卡作为破坏对象
			local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g2>0 then
				-- 手动为所选破坏的卡片显示选择动画
				Duel.HintSelection(g2)
				-- 破坏所选的对方场上卡片
				Duel.Destroy(g2,REASON_EFFECT)
			end
		end
	end
end
