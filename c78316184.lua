--サイバー・エンジェル－美朱濡－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。从额外卡组特殊召唤的对方场上的怪兽全部破坏，给与对方破坏的怪兽数量×1000伤害。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：1回合1次，要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时，让自己墓地1只仪式怪兽回到卡组才能发动。那个发动无效并破坏。
function c78316184.initial_effect(c)
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
-- 判断此卡是否通过仪式召唤成功
function c78316184.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 过滤函数：检查怪兽是否是从额外卡组特殊召唤的
function c78316184.desfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动准备与效果分类设置：检查对方场上是否存在从额外卡组特殊召唤的怪兽，并设置破坏与伤害的操作信息
function c78316184.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只从额外卡组特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78316184.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有从额外卡组特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c78316184.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害的操作信息，对象为对方玩家，数值为破坏怪兽数量×1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*1000)
end
-- 效果①的实际处理：破坏对方场上从额外卡组特殊召唤的怪兽，给予对方相应伤害，并赋予自身在同一次战斗阶段中可以作2次攻击的效果
function c78316184.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有从额外卡组特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c78316184.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏这些怪兽，并获取实际被破坏的怪兽数量
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		-- 给予对方玩家破坏数量×1000的伤害
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
-- 效果②的发动条件判断：此卡未被战斗破坏，且当前连锁的效果可以被无效，且该效果包含破坏场上卡片的操作
function c78316184.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡已被战斗破坏，或当前连锁的发动无法被无效，则不能发动
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若当前连锁是为了无效其他卡的发动而发动的魔法·陷阱卡，则不能发动（防止对无效类效果进行套娃响应）
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁中关于破坏卡片的操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤函数：检查自己墓地是否存在可以回到卡组的仪式怪兽
function c78316184.costfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToDeckAsCost()
end
-- 效果②的消耗（Cost）处理：让自己墓地1只仪式怪兽回到卡组
function c78316184.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少1只仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78316184.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c78316184.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向双方玩家展示所选择的卡片
	Duel.HintSelection(g)
	-- 将选中的仪式怪兽作为Cost送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果②的发动准备：设置无效发动与破坏卡片的操作信息
function c78316184.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该卡可以被破坏且仍在场，则设置破坏该卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的实际处理：使该效果的发动无效并破坏
function c78316184.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该效果的发动无效，且该卡在场上（或与效果关联）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
