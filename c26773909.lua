--才呼粉身
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段以自己场上1只表侧表示怪兽为对象才能发动。自己失去那只怪兽的攻击力数值的基本分，那只怪兽的攻击力直到回合结束时变成2倍。这张卡发动的回合，作为对象的怪兽不能直接攻击。
function c26773909.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的战斗阶段以自己场上1只表侧表示怪兽为对象才能发动。自己失去那只怪兽的攻击力数值的基本分，那只怪兽的攻击力直到回合结束时变成2倍。这张卡发动的回合，作为对象的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26773909+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c26773909.condition)
	e1:SetTarget(c26773909.target)
	e1:SetOperation(c26773909.activate)
	c:RegisterEffect(e1)
	if not c26773909.global_check then
		c26773909.global_check=true
		-- ①：自己·对方的战斗阶段以自己场上1只表侧表示怪兽为对象才能发动。这张卡发动的回合，作为对象的怪兽不能直接攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c26773909.checkop)
		-- 将全局持续效果 ge1 注册到决斗中，使任意玩家场上的怪兽发动攻击宣言时都会执行 checkop，用于记录本回合进行过直接攻击宣言的怪兽，供本卡选择对象时排除。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言事件的处理：若当前怪兽此前没有直接攻击宣言标记，且本次攻击为直接攻击（无攻击对象），则给该怪兽打上 26773909 标记；该标记持续到回合结束，表示该怪兽本回合已进行过直接攻击。
function c26773909.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 检查该怪兽是否还没有直接攻击宣言标记，以及本次攻击宣言是否没有攻击对象（直接攻击）；满足时才对怪兽进行标记。
	if tc:GetFlagEffect(26773909)==0 and Duel.GetAttackTarget()==nil then
		tc:RegisterFlagEffect(26773909,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 该卡的发动条件：当前阶段必须是战斗阶段中的任一时点（PHASE_BATTLE_START 至 PHASE_BATTLE），且伤害步骤中只能在没有进行伤害计算时发动。
function c26773909.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前决斗阶段，存入局部变量 ph，以便判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回真当且仅当当前阶段在战斗阶段范围内，并且 aux.dscon 确认伤害步骤未进行伤害计算；即只能在战斗阶段且伤害计算前发动。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 选择对象的过滤条件：怪兽必须表侧表示、攻击力不高于发动者当前 LP、且本回合尚未进行过直接攻击宣言。
function c26773909.filter(c,lp)
	return c:IsFaceup() and c:IsAttackBelow(lp) and c:GetFlagEffect(26773909)==0
end
-- 效果发动前的目标处理：确保存在合法对象；玩家选择自己场上 1 只满足条件的表侧表示怪兽作为对象；并在对象确定后立即给它注册“本回合不能直接攻击”的誓约效果，直到回合结束。
function c26773909.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取发动者当前基本分，用于限制所选怪兽攻击力不能超过该数值。
	local lp=Duel.GetLP(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26773909.filter(chkc,lp) end
	-- 在发动合法性确认阶段，检查场上是否存在至少 1 只满足过滤条件的表侧表示怪兽；存在才允许发动。
	if chk==0 then return Duel.IsExistingTarget(c26773909.filter,tp,LOCATION_MZONE,0,1,nil,lp) end
	-- 给发动者显示“请选择表侧表示的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动者从自己场上选择 1 只表侧表示且满足 filter 的怪兽，并设置为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c26773909.filter,tp,LOCATION_MZONE,0,1,1,nil,lp)
	-- 自己失去那只怪兽的攻击力数值的基本分，那只怪兽的攻击力直到回合结束时变成2倍。这张卡发动的回合，作为对象的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	g:GetFirst():RegisterEffect(e1,true)
end
-- 效果处理：取得对象怪兽；若对象仍与效果关联且表侧表示，则令发动者失去其攻击力数值的基本分；若 LP 归零或以下则终止；否则将对象怪兽的攻击力变成当前攻击力的 2 倍，持续到回合结束。
function c26773909.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将发动者基本分减少对象怪兽当前攻击力的数值，即失去对应的基本分。
		Duel.SetLP(tp,Duel.GetLP(tp)-tc:GetAttack())
		-- 如果发动者基本分因此降到 0 或以下，则中止后续处理（不再赋予攻击力翻倍效果）。
		if Duel.GetLP(tp)<=0 then return end
		-- 那只怪兽的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
