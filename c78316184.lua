--サイバー・エンジェル－美朱濡－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。从额外卡组特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×1000伤害。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：1回合1次，要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，让自己墓地1只仪式怪兽回到卡组才能发动。那个发动无效并破坏。
function c78316184.initial_effect(c)
	-- 记录该卡记载了「机械天使的仪式」的卡名
	aux.AddCodeList(c,39996157)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。从额外卡组特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×1000伤害。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78316184,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c78316184.descon)
	e1:SetTarget(c78316184.destg)
	e1:SetOperation(c78316184.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，让自己墓地1只仪式怪兽回到卡组才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78316184,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c78316184.negcon)
	e2:SetCost(c78316184.negcost)
	e2:SetTarget(c78316184.negtg)
	e2:SetOperation(c78316184.negop)
	c:RegisterEffect(e2)
end
-- 判断是否为仪式召唤成功
function c78316184.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤从额外卡组特殊召唤的怪兽
function c78316184.desfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 破坏与伤害效果的目标判断与操作信息设置
function c78316184.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少1只从额外卡组特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78316184.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有从额外卡组特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c78316184.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为：破坏所有从额外卡组特殊召唤的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息为：给与对方破坏数量×1000的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 破坏与伤害效果的具体操作：破坏对方场上所有从额外卡组特殊召唤的怪兽，给与对应伤害，并为自身赋予在同一次战斗阶段中可以作2次攻击的效果
function c78316184.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有从额外卡组特殊召唤的怪兽组
	local g=Duel.GetMatchingGroup(c78316184.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏这些怪兽，并获取实际破坏的怪兽数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 根据实际破坏的怪兽数量给与对方×1000的伤害
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 无效效果的发动条件判断
function c78316184.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若自身已被战斗破坏，或当前连锁的效果无法被无效，则不能发动
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 排除对无效发动效果进行无效的效果的干扰
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁操作中关于“破坏”的分类信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤自己墓地能返回卡组的仪式怪兽
function c78316184.costfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToDeckAsCost()
end
-- 无效效果的发动代价操作：将墓地1只仪式怪兽返回卡组
function c78316184.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地是否存在符合条件的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78316184.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只符合条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c78316184.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 在场上/墓地中高亮显示选中的卡片
	Duel.HintSelection(g)
	-- 将选中的仪式怪兽作为代价洗回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 无效效果的目标判断与操作信息设置
function c78316184.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为：将发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的具体操作：使发动的效果无效并破坏
function c78316184.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功将效果的发动无效，且该卡仍然关联于该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对应的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
