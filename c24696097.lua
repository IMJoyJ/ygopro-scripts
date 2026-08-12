--シューティング・スター・ドラゴン
-- 效果：
-- 同调怪兽调整＋「星尘龙」
-- ①：1回合1次，可以发动。从自己卡组上面翻开5张并回到卡组。这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。
-- ②：1回合1次，要让场上的卡破坏的效果的发动时才能发动。那个效果无效并破坏。
-- ③：1回合1次，对方的攻击宣言时以攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
-- ④：这个③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
function c24696097.initial_effect(c)
	-- 为该怪兽添加融合素材代码列表，允许使用编号为44508094的卡作为素材
	aux.AddMaterialCodeList(c,44508094)
	-- 设置该怪兽的同调召唤条件，要求1只调整怪兽和1只编号为44508094的怪兽作为同调素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.FilterBoolFunction(Card.IsCode,44508094),1,1)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以发动。从自己卡组上面翻开5张并回到卡组。这个回合这张卡可以作出最多有所翻开之中的调整数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24696097,0))  --"多重攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24696097.mtcon)
	e1:SetOperation(c24696097.mtop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，要让场上的卡破坏的效果的发动时才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24696097,1))  --"把卡破坏的效果无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c24696097.discon)
	e2:SetTarget(c24696097.distg)
	e2:SetOperation(c24696097.disop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方的攻击宣言时以攻击怪兽为对象才能发动。场上的这张卡除外，那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24696097,2))  --"无效攻击"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c24696097.dacon)
	e3:SetTarget(c24696097.datg)
	e3:SetOperation(c24696097.daop)
	c:RegisterEffect(e3)
	-- ④：这个③的效果除外的回合的结束阶段发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24696097,3))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1)
	e4:SetCondition(c24696097.sumcon)
	e4:SetTarget(c24696097.sumtg)
	e4:SetOperation(c24696097.sumop)
	c:RegisterEffect(e4)
end
c24696097.material_type=TYPE_SYNCHRO
-- 效果发动条件：确认是否能进入战斗阶段且自己卡组有至少5张牌
function c24696097.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是否能进入战斗阶段且自己卡组有至少5张牌
	return Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
end
-- 效果处理：翻开卡组最上方5张牌，统计其中调整的数量并根据数量设置额外攻击次数或禁止攻击
function c24696097.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 翻开玩家卡组最上方的5张牌
	Duel.ConfirmDecktop(tp,5)
	-- 获取玩家卡组最上方的5张牌组成的牌组
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	-- 将玩家卡组洗牌
	Duel.ShuffleDeck(tp)
	if ct>1 then
		-- 设置该怪兽在本回合可以额外进行ct-1次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct-1)
		c:RegisterEffect(e1)
	elseif ct==0 then
		-- 设置该怪兽在本回合不能进行攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 无效破坏效果发动的条件判断
function c24696097.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 若该怪兽处于战斗破坏状态或该连锁不能被无效则返回false
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若该连锁是被无效的永续魔法效果发动则返回false
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁的破坏效果信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 设置无效破坏效果的目标和破坏目标
function c24696097.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏目标卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使连锁效果无效并破坏目标卡
function c24696097.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效且目标卡存在
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 攻击宣言时的条件判断：攻击方不是自己
function c24696097.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方不是自己
	return Duel.GetAttacker():GetControler()~=tp
end
-- 设置攻击无效效果的目标和条件
function c24696097.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若chkc存在则返回是否为目标攻击怪兽
	if chkc then return chkc==Duel.GetAttacker() end
	-- 判断是否满足发动条件：该怪兽可除外且攻击怪兽可成为目标
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.GetAttacker():IsCanBeEffectTarget(e)
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置当前处理的连锁的目标为攻击怪兽
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置连锁操作信息为除外该怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将该怪兽除外并无效攻击
function c24696097.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 该怪兽可除外且除外成功
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 无效此次攻击
		Duel.NegateAttack()
		c:RegisterFlagEffect(24696097,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
-- 特殊召唤的发动条件：该怪兽在被除外的回合结束阶段
function c24696097.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(24696097)>0
end
-- 设置特殊召唤的效果目标
function c24696097.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将该怪兽特殊召唤到场上
function c24696097.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该怪兽以特殊召唤方式回到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
