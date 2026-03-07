--ファイナル・クロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：同调怪兽被送去自己墓地的自己回合，以自己场上1只同调怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。以原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽为对象把这张卡发动的场合，可以再选自己墓地1只同调怪兽让作为对象的怪兽的攻击力上升那个攻击力数值。
function c35756798.initial_effect(c)
	-- 效果原文内容：①：同调怪兽被送去自己墓地的自己回合，以自己场上1只同调怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。以原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽为对象把这张卡发动的场合，可以再选自己墓地1只同调怪兽让作为对象的怪兽的攻击力上升那个攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,35756798+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c35756798.atkcon)
	e1:SetTarget(c35756798.atktg)
	e1:SetOperation(c35756798.atkop)
	c:RegisterEffect(e1)
	if not c35756798.global_check then
		c35756798.global_check=true
		-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetCondition(c35756798.checkcon)
		ge1:SetOperation(c35756798.checkop)
		-- 注册一个全局的持续效果，用于监听墓地变动事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断是否有同调怪兽被送去墓地
function c35756798.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 当有同调怪兽被送去墓地时，为该怪兽控制者注册一个标识效果，用于标记其回合内已发生过同调怪兽送墓事件
function c35756798.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	local tc=g:GetFirst()
	while tc do
		-- 判断该玩家是否已注册过标识效果
		if Duel.GetFlagEffect(tc:GetControler(),35756798)==0 then
			-- 为该玩家注册一个标识效果，标记其回合内已发生过同调怪兽送墓事件
			Duel.RegisterFlagEffect(tc:GetControler(),35756798,RESET_PHASE+PHASE_END,0,1)
		end
		-- 判断双方是否都已注册过标识效果，若都已注册则跳出循环
		if Duel.GetFlagEffect(0,35756798)>0 and Duel.GetFlagEffect(1,35756798)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 判断是否满足发动条件：当前回合玩家为发动者，且处于可进行战斗操作的阶段，并且该玩家已注册过标识效果
function c35756798.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家注册的标识效果数量
	local ct=Duel.GetFlagEffect(tp,35756798)
	-- 返回是否满足发动条件：当前回合玩家为发动者，且处于可进行战斗操作的阶段，并且该玩家已注册过标识效果
	return Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and ct>0
end
-- 过滤函数，用于筛选满足条件的同调怪兽作为目标
function c35756798.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 设置效果目标：选择场上一只表侧表示的同调怪兽作为对象
function c35756798.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35756798.filter(chkc) end
	-- 检查是否有满足条件的同调怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c35756798.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只表侧表示的同调怪兽作为对象
	local g=Duel.SelectTarget(tp,c35756798.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsOriginalSetCard(0x66,0x1017,0xa3) then
		-- 设置目标参数，表示是否可以发动额外效果
		Duel.SetTargetParam(1)
	end
end
-- 过滤函数，用于筛选墓地中的同调怪兽
function c35756798.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:GetAttack()>0
end
-- 执行效果操作：使目标怪兽获得一次额外攻击机会，并根据是否满足条件决定是否提升攻击力
function c35756798.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中目标参数的值
	local num=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果作用：使目标怪兽在同1次的战斗阶段中可以作2次攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 判断是否满足额外攻击力提升条件：目标参数大于0，且墓地存在满足条件的同调怪兽
		if num>0 and Duel.IsExistingMatchingCard(c35756798.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
			-- 询问玩家是否选择墓地中的同调怪兽以提升攻击力
			and Duel.SelectYesNo(tp,aux.Stringid(35756798,1)) then  --"是否选怪兽以上升攻击力？"
			-- 提示玩家选择墓地中的同调怪兽作为攻击力提升对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
			-- 选择墓地中的同调怪兽作为攻击力提升对象
			local ag=Duel.SelectMatchingCard(tp,c35756798.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			-- 显示所选怪兽被选为对象的动画效果
			Duel.HintSelection(ag)
			-- 效果作用：使目标怪兽的攻击力上升所选怪兽的攻击力数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(ag:GetFirst():GetAttack())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
