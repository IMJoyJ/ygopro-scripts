--イクイップ・シュート
-- 效果：
-- 战斗阶段中才能发动。选择自己场上表侧攻击表示存在的怪兽装备的1张装备卡和对方场上存在的1只表侧攻击表示的怪兽，把选择的装备卡给选择的对方怪兽装备。那之后，选择的装备卡装备过的自己怪兽和选择的对方怪兽进行战斗进行伤害计算。
function c62878208.initial_effect(c)
	-- 战斗阶段中才能发动。选择自己场上表侧攻击表示存在的怪兽装备的1张装备卡和对方场上存在的1只表侧攻击表示的怪兽，把选择的装备卡给选择的对方怪兽装备。那之后，选择的装备卡装备过的自己怪兽和选择的对方怪兽进行战斗进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c62878208.eqcon)
	e1:SetTarget(c62878208.eqtg)
	e1:SetOperation(c62878208.eqop)
	c:RegisterEffect(e1)
end
-- 定义发动条件、效果对象选择和效果处理的整体流程。
function c62878208.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始步骤到战斗阶段结束步骤）。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤自己场上表侧攻击表示怪兽装备的装备卡，且对方场上存在可装备该卡的目标怪兽。
function c62878208.filter1(c,e,tp)
	local ec=c:GetEquipTarget()
	return ec and ec:IsControler(tp) and ec:IsPosition(POS_FACEUP_ATTACK)
		-- 检查对方场上是否存在可以装备该装备卡的表侧攻击表示怪兽。
		and Duel.IsExistingTarget(c62878208.filter2,tp,0,LOCATION_MZONE,1,nil,c)
end
-- 过滤对方场上表侧攻击表示且该装备卡可以合法装备的怪兽。
function c62878208.filter2(c,ec)
	return c:IsPosition(POS_FACEUP_ATTACK) and ec:CheckEquipTarget(c)
end
-- 定义效果发动的对象选择（Target）函数，依次选择装备卡和对方怪兽作为对象。
function c62878208.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查场上是否存在至少1张满足条件的装备卡作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(c62878208.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,tp) end
	-- 提示玩家选择要转移给对方的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62878208,0))  --"请选择要给对方装备的装备卡"
	-- 选择自己场上表侧攻击表示怪兽装备的1张装备卡作为第1个效果对象，并将其记录在LabelObject中。
	local g1=Duel.SelectTarget(tp,c62878208.filter1,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择表侧攻击表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择对方场上1只表侧攻击表示且能装备该装备卡的怪兽作为第2个效果对象。
	local g2=Duel.SelectTarget(tp,c62878208.filter2,tp,0,LOCATION_MZONE,1,1,nil,g1:GetFirst())
end
-- 定义效果处理（Operation）函数，执行装备转移和强制伤害计算。
function c62878208.eqop(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetLabelObject()
	local eqc=eq:GetEquipTarget()
	-- 获取当前连锁中被选择为效果对象的卡片组（包含装备卡和对方怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if eq==tc then tc=g:GetNext() end
	if eqc and eq:IsRelateToEffect(e) then
		-- 将选择的装备卡装备给选择的对方怪兽，若装备失败则直接结束效果处理。
		if not Duel.Equip(tp,eq,tc) then return end
		-- 中断效果处理，使之后的伤害计算与装备处理不视为同时进行。
		Duel.BreakEffect()
		local a=eqc
		local d=tc
		-- 判断当前回合玩家是否不是自己，以确定伤害计算时的攻击方（回合玩家的怪兽视为攻击方）。
		if Duel.GetTurnPlayer()~=tp then
			a=tc
			d=eqc
		end
		if a:IsAttackable() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
			-- 令原装备怪兽与对方怪兽进行战斗并进行伤害计算。
			Duel.CalculateDamage(a,d,true)
		end
	end
end
