--糾罪巧－Aizaβ.LEON
-- 效果：
-- ←0 【灵摆】 0→
-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽效果】
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤）。从手卡把1只怪兽里侧守备表示特殊召唤。
-- ②：对方连锁自己的效果的发动把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。场上最多3张卡回到手卡。
-- ③：只要反转过的这张卡在怪兽区域存在，对方每次自身的卡的效果让自身手卡有卡加入，受到每1张900伤害。
local s,id,o=GetID()
-- 声明initial_effect函数，添加灵摆属性，注册指示物及灵摆区破坏、手卡特召、反转回手、伤害等效果
function s.initial_effect(c)
	-- 为灵摆怪兽添加灵摆召唤支持
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x71,LOCATION_PZONE)
	-- ①：每次怪兽反转，给这张卡放置1个纠罪指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetRange(LOCATION_PZONE)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	-- ②：自己·对方的战斗阶段结束时，另一边的自己的灵摆区域有「纠罪巧」卡存在的场合，以比这张卡攻击力低的对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：对方连锁自己的效果的发动把卡的效果发动时，把里侧表示的这张卡变成表侧守备表示才能发动。场上最多3张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：只要反转过的这张卡在怪兽区域存在
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	-- 对方每次自身的卡的效果让自身手卡有卡加入
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon1)
	e5:SetOperation(s.damop1)
	c:RegisterEffect(e5)
	-- 受到每1张900伤害
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_TO_HAND)
	e6:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.regcon)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	-- 受到每1张900伤害
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAIN_SOLVED)
	e7:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.damcon2)
	e7:SetOperation(s.damop2)
	c:RegisterEffect(e7)
	-- 设置记录特殊召唤操作类型的自定义计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.mentioned_counter={
	[0x71]=true,
}
-- 过滤条件：判断是否为里侧表示状态
function s.counterfilter(c)
	return c:IsFacedown()
end
-- 给这张卡放置1个纠罪指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x71,1)
end
-- 过滤条件：判断是否为名字带有「纠罪巧」的卡
function s.cfilter(c)
	return c:IsSetCard(0x1d4)
end
-- 判断另一边的自己的灵摆区域是否有「纠罪巧」卡存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 另一边的自己的灵摆区域有「纠罪巧」卡存在的场合
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 过滤条件：判断是否为比此卡攻击力低的表侧表示怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 判断指定卡片是否为对方场上攻击力低于此卡的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetBaseAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and s.desfilter(chkc,atk) end
	-- 判断对方场上是否存在比这张卡攻击力低的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以比这张卡攻击力低的对方场上1只怪兽为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
	-- 设置破坏卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理破坏对方目标怪兽的效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 把手卡的这张卡给对方观看才能发动，并检查誓约
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不用里侧守备表示不能把怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将无法使用里侧守备表示以外方式特殊召唤的誓约效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断特殊召唤的形式是否为表侧表示
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumpos&POS_FACEUP)>0
end
-- 判断卡片是否能里侧守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否有怪兽区空位及手卡是否有可特殊召唤的怪兽，设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断是否受到禁止里侧表示特殊召唤的效果影响
		if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DIVINE_LIGHT) then
			return false
		end
		-- 检查是否有可用的怪兽区空间
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡是否存在能里侧守备表示特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤手卡怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 让玩家选择手卡中的怪兽并里侧守备表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有可用的怪兽区空间则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择手卡中1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 手动洗切自己手卡
	Duel.ShuffleHand(tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		local hint=sc:IsPublic()
		-- 从手卡把1只怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		if hint then
			-- 将被公开的手卡特召怪兽向对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断对方是否连锁自己的效果发动效果且此卡在场上里侧表示
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取上一个连锁效果的发动信息及发动玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandlerPlayer()==tp and ep~=tp and e:GetHandler():IsFacedown()
end
-- 把里侧表示的这张卡变成表侧守备表示才能发动
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把里侧表示的这张卡变成表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 判断场上是否有可回手的卡，并设置返回手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以返回手卡的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置卡片返回手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 让玩家选择场上最多3张卡并返回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上最多3张可返回手卡的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,3,nil)
	if #g>0 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 场上最多3张卡回到手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 当怪兽反转时，给这张卡注册已反转过的标记
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已反转过"
	c:SetStatus(STATUS_EFFECT_ENABLED,true)
end
-- 判断此卡是否已反转过且对方因效果向手卡加入卡片（不入连锁处理）
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 判断对方是否向手卡加入卡片且当前不在连锁处理中
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and not Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 造成对方加入手卡的数量乘900的伤害
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 发出卡片效果触发的提示
	Duel.Hint(HINT_CARD,0,id)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	-- 受到每1张900伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
-- 判断此卡是否已反转过且对方因效果向手卡加入卡片（入连锁处理中，暂存伤害标记）
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
		-- 判断对方是否向手卡加入卡片且当前在连锁处理中
		and eg:IsExists(Card.IsControler,1,nil,1-tp) and Duel.IsChainSolving()
		and re and re:GetOwnerPlayer()==1-tp
end
-- 给这张卡注册临时标记记录对方加入手卡的数量
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	e:GetHandler():RegisterFlagEffect(id+o,RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_CHAIN,0,1,ct)
end
-- 判断这张卡是否存有在连锁处理中记录的对方加入手卡数量标记
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+o)>0
end
-- 在连锁处理结束后，统一结算累积记录的对方加入手卡的伤害
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 发出卡片效果触发的提示
	Duel.Hint(HINT_CARD,0,id)
	local labels={e:GetHandler():GetFlagEffectLabel(id+o)}
	local ct=0
	for i=1,#labels do ct=ct+labels[i] end
	e:GetHandler():ResetFlagEffect(id+o)
	-- 结算伤害，给与对方累积加入手卡数量乘以900的伤害
	Duel.Damage(1-tp,ct*900,REASON_EFFECT)
end
