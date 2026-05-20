--星遺物の囁き
-- 效果：
-- ①：这张卡的发动时，可以以场上1只5星以上的怪兽为对象。那个场合，那只怪兽的攻击力·守备力直到回合结束时上升1000。
-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方的魔法卡的效果无效化。
function c62530723.initial_effect(c)
	-- ①：这张卡的发动时，可以以场上1只5星以上的怪兽为对象。那个场合，那只怪兽的攻击力·守备力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c62530723.target)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方的魔法卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c62530723.discon)
	e2:SetOperation(c62530723.disop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且等级在5星以上的怪兽
function c62530723.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 效果①的发动时对象选择与处理分支判定
function c62530723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c62530723.atkfilter(chkc) end
	if chk==0 then
		-- 判定当前是否处于伤害步骤
		if Duel.GetCurrentPhase()==PHASE_DAMAGE then
			-- 检查场上是否存在可以作为对象的5星以上怪兽
			return Duel.IsExistingTarget(c62530723.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		end
		return true
	end
	-- 判定当前是否处于伤害步骤
	if Duel.GetCurrentPhase()==PHASE_DAMAGE
		-- 或者场上是否存在可选的5星以上怪兽
		or (Duel.IsExistingTarget(c62530723.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且玩家选择发动该追加效果
		and Duel.SelectYesNo(tp,aux.Stringid(62530723,0))) then  --"是否选怪兽上升攻击力？"
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c62530723.activate)
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择场上1只表侧表示的5星以上怪兽作为效果对象
		Duel.SelectTarget(tp,c62530723.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		e:SetOperation(nil)
	end
end
-- 效果①的生效处理，使目标怪兽的攻击力·守备力直到回合结束时上升1000
function c62530723.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤自己场上与对方发动魔法卡相同纵列的表侧表示「机界骑士」怪兽
function c62530723.cfilter(c,seq2)
	-- 获取怪兽在怪兽区的实际纵列序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0x10c) and seq1==4-seq2
end
-- 判定是否满足无效对方魔法卡效果的条件
function c62530723.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的卡片所在的位置和纵列序号
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and loc&LOCATION_SZONE==LOCATION_SZONE and seq<=4
		-- 检查自己场上相同纵列是否存在「机界骑士」怪兽
		and Duel.IsExistingMatchingCard(c62530723.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 执行无效魔法卡效果的操作
function c62530723.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显式展示此卡，提示正在适用其效果
	Duel.Hint(HINT_CARD,0,62530723)
	-- 无效该连锁的效果
	Duel.NegateEffect(ev)
end
