--鋼鉄の魔導騎士－ギルティギア・フリード
-- 效果：
-- 属性不同的战士族怪兽×2
-- ①：1回合1次，这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效，选场上1张卡破坏。
-- ②：只用场上的怪兽为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，从自己墓地把1张魔法卡除外才能发动。这张卡的攻击力直到回合结束时上升这张卡的守备力一半数值。
function c49161188.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，允许以2只属性不同的战士族怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFunRep(c,c49161188.ffilter,2,true)
	-- ①：1回合1次，这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效，选场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49161188,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49161188.discon)
	e1:SetTarget(c49161188.distg)
	e1:SetOperation(c49161188.disop)
	c:RegisterEffect(e1)
	-- ②：只用场上的怪兽为素材作融合召唤的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49161188.matcheck)
	c:RegisterEffect(e2)
	-- ②：在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	e3:SetLabelObject(e2)
	e3:SetCondition(c49161188.xacon)
	c:RegisterEffect(e3)
	-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，从自己墓地把1张魔法卡除外才能发动。这张卡的攻击力直到回合结束时上升这张卡的守备力一半数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(49161188,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c49161188.atkcon)
	e4:SetCost(c49161188.atkcost)
	e4:SetOperation(c49161188.atkop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数：筛选战士族怪兽，并保证与已选素材属性不同，用于凑成“属性不同的战士族怪兽×2”的融合素材。
function c49161188.ffilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_WARRIOR) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- ①的发动条件：这张卡成为魔法·陷阱·怪兽效果的对象，且该效果可被无效时才能发动；同时若这张卡已确定被战斗破坏则不能发动。
function c49161188.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁效果的对象卡集合，用于判断这张卡是否被选为对象。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象集合中包含这张卡且该连锁效果可以被无效，从而满足①的发动条件。
	return tg and tg:IsContains(e:GetHandler()) and Duel.IsChainDisablable(ev)
end
-- ①的发动时处理：设置“使效果无效”和“破坏1张卡”的操作信息，并检索场上所有卡作为破坏候选。
function c49161188.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果操作包含“无效效果”分类，对象为当前触发连锁的卡/效果，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 获取双方场上所有卡，作为“选场上1张卡破坏”的候选集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置本次效果操作包含“破坏”分类，候选目标为场上所有卡，处理时选1张破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①的效果处理：先无效对方发动的效果，若成功，则从场上选1张卡破坏。
function c49161188.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前连锁的效果，成功才继续执行后续破坏处理。
	if Duel.NegateEffect(ev) then
		-- 从双方场上选择1张卡作为要破坏的卡。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选择的卡并标记为对象，进行选牌动画提示。
			Duel.HintSelection(g)
			-- 将被选择的卡以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 检查融合素材是否全部来自场上（主要怪兽区），将结果记录在效果标签中，供额外攻击条件判断使用。
function c49161188.matcheck(e,c)
	local g=c:GetMaterial()
	local res=true
	local tc=g:GetFirst()
	while tc do
		res=res and tc:IsLocation(LOCATION_MZONE)
		tc=g:GetNext()
	end
	if res then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 额外攻击的发动条件：这张卡是融合召唤，且融合素材全部来自场上怪兽时，允许增加攻击次数。
function c49161188.xacon(e)
	local flag=e:GetLabelObject():GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and flag==1
end
-- ③的发动条件：这张卡与对方怪兽进行战斗的伤害计算时，且自身守备力大于0。
function c49161188.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and c:GetDefense()>0
end
-- 墓地除外cost的过滤函数：选择墓地中的魔法卡，且能够作为除外代价。
function c49161188.atkfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ③的cost处理：从自己墓地选择1张魔法卡除外作为发动代价。
function c49161188.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动③前检查自己墓地是否存在至少1张可除外的魔法卡作为cost。
	if chk==0 then return Duel.IsExistingMatchingCard(c49161188.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的魔法卡。
	local g=Duel.SelectMatchingCard(tp,c49161188.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的魔法卡以表侧表示除外，支付发动cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③的效果处理：若这张卡仍与战斗相关且表侧表示，攻击力上升守备力一半数值直到回合结束。
function c49161188.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		-- ③：这张卡的攻击力直到回合结束时上升这张卡的守备力一半数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(c:GetDefense()/2)
		c:RegisterEffect(e1)
	end
end
