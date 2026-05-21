--サイバー・エンジェル－伊舎那－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1张魔法·陷阱卡送去墓地。
-- ②：这张卡的攻击破坏对方怪兽送去墓地时才能发动。这张卡只再1次可以继续向对方怪兽攻击。
-- ③：1回合1次，自己场上的「电子化天使」仪式怪兽为对象的对方的效果发动时才能发动。选自己墓地1只仪式怪兽回到卡组，选对方场上1张卡破坏。
function c91668401.initial_effect(c)
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
-- 检查此卡是否通过仪式召唤特殊召唤
function c91668401.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果①的发动准备与合法性检测，若可行则设置对方场上魔陷送墓的操作信息
function c91668401.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方魔陷区是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>0 end
	-- 设置当前连锁的操作信息，表示该效果会将对方魔陷区的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_SZONE)
end
-- 效果①的处理：让对方选择自身场上1张魔法·陷阱卡送去墓地
function c91668401.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方魔陷区的所有卡
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_SZONE,0,nil)
	if #g>0 then
		-- 提示对方玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 显式展示对方选择的卡
		Duel.HintSelection(sg)
		-- 对方玩家因规则（非效果）将选中的卡送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 效果②的发动条件：此卡攻击破坏对方怪兽送去墓地，且此卡可以继续攻击
function c91668401.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 检查此卡是否为攻击怪兽、是否仍在战斗中、是否击败了对方怪兽，以及是否可以进行追加攻击
	return c==Duel.GetAttacker() and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE) and c:IsChainAttackable(2,true)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 效果②的处理：使此卡可以再进行1次攻击，并限制不能直接攻击
function c91668401.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 允许该怪兽继续进行下一次攻击
		Duel.ChainAttack()
		-- 继续向对方怪兽攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤属于自己场上的「电子化天使」仪式怪兽
function c91668401.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x2093) and c:IsType(TYPE_RITUAL)
end
-- 效果③的发动条件：对方发动了以自己场上「电子化天使」仪式怪兽为对象的效果
function c91668401.descon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c91668401.cfilter,1,nil,tp)
end
-- 过滤自己墓地可以回到卡组的仪式怪兽
function c91668401.tdfilter(c)
	return c:GetType()&0x81==0x81 and c:IsAbleToDeck()
end
-- 效果③的发动准备与合法性检测，若可行则设置回收和破坏的操作信息
function c91668401.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91668401.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且对方场上存在至少1张卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息，表示该效果会将自己墓地的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置当前连锁的操作信息，表示该效果会破坏对方场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的处理：将自己墓地1只仪式怪兽回到卡组，并破坏对方场上1张卡
function c91668401.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地的一只仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c91668401.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 显式展示选择的墓地怪兽
		Duel.HintSelection(g)
		-- 将选中的怪兽送回卡组并洗牌，若成功则继续执行
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择对方场上的1张卡
			local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g2>0 then
				-- 显式展示选择的对方场上的卡
				Duel.HintSelection(g2)
				-- 破坏选中的对方场上的卡
				Duel.Destroy(g2,REASON_EFFECT)
			end
		end
	end
end
