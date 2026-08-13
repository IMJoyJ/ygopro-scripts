--ファイナル・クロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：同调怪兽被送去自己墓地的自己回合，以自己场上1只同调怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。以原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽为对象把这张卡发动的场合，可以再选自己墓地1只同调怪兽让作为对象的怪兽的攻击力上升那个攻击力数值。
function c35756798.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：同调怪兽被送去自己墓地的自己回合，以自己场上1只同调怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。以原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽为对象把这张卡发动的场合，可以再选自己墓地1只同调怪兽让作为对象的怪兽的攻击力上升那个攻击力数值。
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
		-- 同调怪兽被送去自己墓地的自己回合，以自己场上1只同调怪兽为对象才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetCondition(c35756798.checkcon)
		ge1:SetOperation(c35756798.checkop)
		-- 将检测同调怪兽送去墓地的全场持续效果注册到场地（玩家0），使任意玩家的同调怪兽被送去墓地时触发后续的记录逻辑。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断送去墓地的事件组中是否包含至少1只同调怪兽，作为全局记录效果是否执行的过滤条件。
function c35756798.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 当有同调怪兽被送去墓地时，为这只怪兽的控制者注册一个回合结束阶段重置的flag，记录该玩家本回合有同调怪兽被送去自己墓地；若双方都已记录，则提前结束遍历。
function c35756798.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	local tc=g:GetFirst()
	while tc do
		-- 检查该同调怪兽的控制者是否还没有本回合同调怪兽送去墓地的flag；若没有，才需要注册。
		if Duel.GetFlagEffect(tc:GetControler(),35756798)==0 then
			-- 为该玩家注册一个回合结束阶段重置的flag（编号35756798），用于标记其在本回合有同调怪兽被送去自己墓地。
			Duel.RegisterFlagEffect(tc:GetControler(),35756798,RESET_PHASE+PHASE_END,0,1)
		end
		-- 若玩家0和玩家1都已拥有35756798标记，说明双方本回合都已有同调怪兽被送去墓地，满足记录目的，则跳过后续遍历。
		if Duel.GetFlagEffect(0,35756798)>0 and Duel.GetFlagEffect(1,35756798)>0 then
			break
		end
		tc=g:GetNext()
	end
end
-- 定义卡片的发动条件：必须是己方回合、且处于战斗阶段或可以进入战斗阶段，并且本回合自己墓地有同调怪兽被送去（flag>0）。
function c35756798.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前玩家tp的35756798标记数量，用于判断本回合是否有同调怪兽被送去tp的墓地。
	local ct=Duel.GetFlagEffect(tp,35756798)
	-- 返回发动条件是否满足：当前回合玩家是tp、处于战斗阶段或可进入战斗阶段、且tp已有同调怪兽被送去墓地的flag。
	return Duel.GetTurnPlayer()==tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and ct>0
end
-- 定义效果对象的选择条件：表侧表示、是同调怪兽、且没有被赋予额外攻击次数效果（避免重复叠加类似效果）。
function c35756798.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果发动的目标选择处理：检查对象合法性；存在可选目标时提示玩家选择自己场上1只表侧表示同调怪兽作为对象；若该对象原本卡名包含「战士」、「同调士」、「星尘」之一，则将连锁参数设为1，以触发追加效果。
function c35756798.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35756798.filter(chkc) end
	-- 在效果发动时（chk==0）检查是否存在至少1只满足条件（表侧同调且无额外攻击次数效果）的自己场上怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c35756798.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示提示消息，要求其选择表侧表示的卡（选择同调怪兽对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的表侧同调怪兽，并将其记录为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,c35756798.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsOriginalSetCard(0x66,0x1017,0xa3) then
		-- 将当前连锁的目标参数设置为1，表示所选对象是原本卡名包含「战士」、「同调士」、「星尘」之一的同调怪兽，供处理阶段判断是否追加墓地升攻效果。
		Duel.SetTargetParam(1)
	end
end
-- 定义墓地可选卡的条件：是同调怪兽，且攻击力数值大于0，以它作为攻击力上升的参照。
function c35756798.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:GetAttack()>0
end
-- 效果处理：先给对象怪兽赋予本回合额外攻击1次的效果（使其可攻击2次）；若连锁参数num>0且自己墓地存在符合条件的同调怪兽且玩家确认，则再选择墓地1只同调怪兽，将其攻击力数值加到对象怪兽上。
function c35756798.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 读取当前连锁的目标参数num，用于判断发动时选择的对象是否属于特定系列的同调怪兽。
	local num=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 取得这张卡效果发动时选择的目标怪兽（对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 判断是否满足追加效果的条件：连锁参数num>0（目标为特定系列同调怪兽）且自己墓地存在至少1只符合条件的同调怪兽。
		if num>0 and Duel.IsExistingMatchingCard(c35756798.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
			-- 若上述条件满足，再询问玩家是否选择墓地同调怪兽上升攻击力；只有玩家选择“是”才执行追加处理。
			and Duel.SelectYesNo(tp,aux.Stringid(35756798,1)) then  --"是否选怪兽以上升攻击力？"
			-- 向玩家显示提示消息，要求其选择效果的对象（从墓地选择同调怪兽）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
			-- 让玩家从自己墓地选择1只满足atkfilter条件的同调怪兽，作为攻击力上升数值的参照。
			local ag=Duel.SelectMatchingCard(tp,c35756798.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			-- 为选中的墓地同调怪兽播放选中动画，并将其记录为效果对象（用于关联判定）。
			Duel.HintSelection(ag)
			-- 可以再选自己墓地1只同调怪兽让作为对象的怪兽的攻击力上升那个攻击力数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(ag:GetFirst():GetAttack())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
