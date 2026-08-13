--破壊神の系譜
-- 效果：
-- 把对方场上守备表示存在的怪兽破坏的回合，选择自己场上表侧表示存在的1只8星的怪兽发动。这个回合，选择怪兽在同1次的战斗阶段中可以作2次攻击。
function c29307554.initial_effect(c)
	-- 把对方场上守备表示存在的怪兽破坏的回合，选择自己场上表侧表示存在的1只8星的怪兽发动。这个回合，选择怪兽在同1次的战斗阶段中可以作2次攻击。
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
		-- 把对方场上守备表示存在的怪兽破坏的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c29307554.checkop)
		-- 将破坏检测用持续效果注册为全场效果，监听所有怪兽被破坏的事件，用于判断本回合是否有“对方场上守备怪兽被己方破坏”发生。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 破坏事件处理函数：遍历被破坏的怪兽，若其破坏前位于怪兽区且为守备表示，则根据破坏原因玩家和被破坏怪兽原控制者判断是哪位玩家达成了“对方守备怪兽被破坏”的条件；若破坏原因是0号玩家且被破坏怪兽原控制者是1号玩家，说明0号玩家破坏了对方守备怪兽，置p1=true；若破坏原因是1号玩家且被破坏怪兽原控制者是0号玩家，说明1号玩家破坏了对方守备怪兽，置p2=true。
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
	-- 若玩家0本回合破坏了对方守备怪兽，则给玩家0注册一个到结束阶段重置的标识（代码29307554），作为其发动本卡的资格标记。
	if p1 then Duel.RegisterFlagEffect(0,29307554,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1本回合破坏了对方守备怪兽，则给玩家1注册一个到结束阶段重置的标识（代码29307554），作为其发动本卡的资格标记。
	if p2 then Duel.RegisterFlagEffect(1,29307554,RESET_PHASE+PHASE_END,0,1) end
end
-- 发动条件判定函数：判断当前玩家是否满足本回合破坏过对方守备怪兽、是回合玩家且处于战斗阶段（或可进入战斗阶段）等条件，只有满足时才允许发动此卡。
function c29307554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回发动条件的具体逻辑：存在29307554标识、当前玩家是回合玩家、且处于/可进入战斗阶段（aux.bpcon）。
	return Duel.GetFlagEffect(tp,29307554)~=0 and Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 可选目标过滤器：要求怪兽为表侧表示、等级在8以上、且当前没有受到额外攻击次数效果影响（避免重复叠加）。
function c29307554.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
-- 发动时指定对象函数：先校验选择的对象合法（自己怪兽区、表侧、等级8以上），再确认存在至少1个可选对象，最后提示玩家选择1只符合条件的怪兽作为效果对象。
function c29307554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29307554.filter(chkc) end
	-- 在发动时点检查：是否存在至少1只符合过滤条件的怪兽可以作为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c29307554.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家发送选择提示，提示内容为“请选择表侧表示的卡”，用于选择卡牌时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从自己场上选择1只符合过滤条件的怪兽作为本卡效果的对象，并自动记录为当前连锁的对象（取对象）。
	Duel.SelectTarget(tp,c29307554.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：获取发动时选择的对象，若该对象仍与效果相关，则给它赋予额外攻击次数+1的效果，持续到回合结束，使其在同一战斗阶段可进行2次攻击。
function c29307554.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
