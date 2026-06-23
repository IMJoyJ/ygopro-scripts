--DD魔導賢者ニコラ
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，从手卡丢弃1只「DDD」怪兽，以自己场上1只6星以下的「DD」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2000。
-- 【怪兽效果】
-- 「DD 魔导贤者 尼古拉」的怪兽效果1回合只能使用1次。
-- ①：这张卡在灵摆区域被破坏的场合，以自己场上1只「DDD」怪兽为对象才能发动。那只怪兽回到持有者手卡，从自己的额外卡组选最多2只表侧表示的「DD」灵摆怪兽在自己的灵摆区域放置。那些卡的灵摆效果在这个回合不能发动。
function c46035545.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46035545.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1只「DDD」怪兽，以自己场上1只6星以下的「DD」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46035545,0))  --"攻守变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c46035545.atkcost)
	e2:SetTarget(c46035545.atktg)
	e2:SetOperation(c46035545.atkop)
	c:RegisterEffect(e2)
	-- ①：这张卡在灵摆区域被破坏的场合，以自己场上1只「DDD」怪兽为对象才能发动。那只怪兽回到持有者手卡，从自己的额外卡组选最多2只表侧表示的「DD」灵摆怪兽在自己的灵摆区域放置。那些卡的灵摆效果在这个回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,46035545)
	e3:SetCondition(c46035545.thcon)
	e3:SetTarget(c46035545.thtg)
	e3:SetOperation(c46035545.thop)
	c:RegisterEffect(e3)
end
-- 限制非DD怪兽进行灵摆召唤
function c46035545.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 筛选手卡中可丢弃的DDD怪兽
function c46035545.atkcfilter(c)
	return c:IsSetCard(0x10af) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 支付1只DDD怪兽作为代价丢入弃牌堆
function c46035545.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的DDD怪兽用于丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(c46035545.atkcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃操作，将符合条件的怪兽从手卡丢弃
	Duel.DiscardHand(tp,c46035545.atkcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选场上满足条件的DD怪兽（6星以下且表侧表示）
function c46035545.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsLevelBelow(6)
end
-- 设置效果目标，选择场上满足条件的DD怪兽
function c46035545.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46035545.atkfilter(chkc) end
	-- 检查是否存在满足条件的DD怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c46035545.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的DD怪兽作为效果对象
	Duel.SelectTarget(tp,c46035545.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行攻击力和守备力提升效果
function c46035545.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为选中的怪兽增加2000点攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 判断此卡是否从灵摆区域被破坏
function c46035545.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE)
end
-- 筛选场上可送回手牌的DDD怪兽
function c46035545.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:IsAbleToHand()
end
-- 筛选额外卡组中可放置到灵摆区的DD灵摆怪兽
function c46035545.pfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 设置效果目标并检查是否满足发动条件
function c46035545.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46035545.thfilter(chkc) end
	-- 检查是否存在满足条件的DDD怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c46035545.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家场上是否有空闲的灵摆区域
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查额外卡组中是否存在满足条件的DD灵摆怪兽
		and Duel.IsExistingMatchingCard(c46035545.pfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择场上满足条件的DDD怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c46035545.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，记录将要送回手牌的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行灵摆区域破坏后的效果处理
function c46035545.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否有效且成功送回手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_HAND) then
		local ct=0
		-- 检查玩家灵摆区0号位置是否可用
		if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
		-- 检查玩家灵摆区1号位置是否可用
		if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
		-- 提示玩家选择要放置到灵摆区的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从额外卡组中选择满足条件的DD灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c46035545.pfilter,tp,LOCATION_EXTRA,0,1,ct,nil)
		local pc=g:GetFirst()
		while pc do
			-- 将选中的灵摆怪兽放置到玩家的灵摆区域
			Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			-- 为放置到灵摆区的怪兽设置不能发动灵摆效果的限制
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			pc:RegisterEffect(e1,true)
			pc=g:GetNext()
		end
	end
end
