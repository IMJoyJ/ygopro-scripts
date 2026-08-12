--鋼鉄の魔導騎士－ギルティギア・フリード
-- 效果：
-- 属性不同的战士族怪兽×2
-- ①：1回合1次，这张卡为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效，选场上1张卡破坏。
-- ②：只用场上的怪兽为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，从自己墓地把1张魔法卡除外才能发动。这张卡的攻击力直到回合结束时上升这张卡的守备力一半数值。
function c49161188.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的战士族怪兽作为融合素材
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
	-- ②：只用场上的怪兽为素材作融合召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c49161188.matcheck)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时，从自己墓地把1张魔法卡除外才能发动。这张卡的攻击力直到回合结束时上升这张卡的守备力一半数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	e3:SetLabelObject(e2)
	e3:SetCondition(c49161188.xacon)
	c:RegisterEffect(e3)
	-- 为卡片添加融合召唤手续，使用2个满足条件的战士族怪兽作为融合素材
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
-- 过滤函数，返回满足种族为战士族且属性不重复的怪兽
function c49161188.ffilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_WARRIOR) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 判断连锁是否可以被无效，确保该卡为对象且效果具有目标属性
function c49161188.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组是否包含此卡，并检查连锁是否可被无效
	return tg and tg:IsContains(e:GetHandler()) and Duel.IsChainDisablable(ev)
end
-- 设置连锁处理时的操作信息，包括使效果无效和破坏场上一张卡
function c49161188.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 获取场上所有满足条件的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏场上一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行连锁无效和破坏操作，若无效成功则选择并破坏场上一张卡
function c49161188.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使当前连锁的效果无效
	if Duel.NegateEffect(ev) then
		-- 选择场上一张卡作为破坏对象
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选中卡片的动画效果
			Duel.HintSelection(g)
			-- 以效果原因破坏选定的卡片
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 检查融合召唤时使用的素材是否全部在主要怪兽区
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
-- 判断此卡是否为融合召唤且使用了场上的怪兽作为素材
function c49161188.xacon(e)
	local flag=e:GetLabelObject():GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and flag==1
end
-- 判断此卡是否参与战斗且对方有怪兽被攻击
function c49161188.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and c:GetDefense()>0
end
-- 过滤函数，返回可作为除外费用的魔法卡
function c49161188.atkfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 设置发动效果时的费用，从墓地选择一张魔法卡除外
function c49161188.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的魔法卡在墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c49161188.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张魔法卡作为除外费用
	local g=Duel.SelectMatchingCard(tp,c49161188.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选定的魔法卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置攻击力提升效果，提升值为守备力的一半
function c49161188.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		-- 使此卡的攻击力在回合结束时上升其守备力一半数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(c:GetDefense()/2)
		c:RegisterEffect(e1)
	end
end
