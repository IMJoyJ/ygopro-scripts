--破壊神の系譜
-- 效果：
-- 把对方场上守备表示存在的怪兽破坏的回合，选择自己场上表侧表示存在的1只8星的怪兽发动。这个回合，选择怪兽在同1次的战斗阶段中可以作2次攻击。
function c29307554.initial_effect(c)
	-- 发动效果：将此卡作为永续魔法卡发动，选择自己场上表侧表示存在的1只8星的怪兽作为对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c29307554.condition)
	e1:SetTarget(c29307554.target)
	e1:SetOperation(c29307554.activate)
	c:RegisterEffect(e1)
	if not c29307554.global_check then
		c29307554.global_check=true
		-- 注册一个全局效果，用于监听对方场上守备表示存在的怪兽被破坏的事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c29307554.checkop)
		-- 将效果ge1注册到玩家0（即场上的玩家）的全局环境中
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽被破坏时，检查该怪兽是否为对方场上守备表示破坏的怪兽，并为对应玩家注册标识效果
function c29307554.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsPreviousPosition(POS_DEFENSE) then
			if tc:GetReasonPlayer()==0 and tc:GetPreviousControler()==1 then p1=true end
			if tc:GetReasonPlayer()==1 and tc:GetPreviousControler()==0 then p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若玩家0的场上存在守备表示被破坏的怪兽，则为玩家0注册标识效果
	if p1 then Duel.RegisterFlagEffect(0,29307554,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1的场上存在守备表示被破坏的怪兽，则为玩家1注册标识效果
	if p2 then Duel.RegisterFlagEffect(1,29307554,RESET_PHASE+PHASE_END,0,1) end
end
-- 效果发动条件：当前回合玩家拥有标识效果且处于可以进行战斗操作的阶段
function c29307554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值为true表示当前回合玩家拥有标识效果且处于可以进行战斗操作的阶段
	return Duel.GetFlagEffect(tp,29307554)~=0 and Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数：筛选出自己场上表侧表示存在的8星以上且未拥有额外攻击次数的怪兽
function c29307554.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
-- 选择目标：选择自己场上表侧表示存在的1只8星以上的怪兽作为效果对象
function c29307554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29307554.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c29307554.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c29307554.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果：使选择的怪兽在本回合的战斗阶段中可以进行2次攻击
function c29307554.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 为选择的怪兽注册额外攻击次数效果，使其在本回合可以进行2次攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
