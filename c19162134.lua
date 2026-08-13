--エンタメデュエル
-- 效果：
-- ①：只要这张卡在场地区域存在，双方玩家每次在1回合中各把以下条件满足，每1个条件在1回合各有1次从卡组抽2张。
-- ●把等级不同的怪兽5只同时特殊召唤。
-- ●自身1只怪兽进行5次战斗。
-- ●连锁5以上把卡的效果发动。
-- ●掷骰子的次数以及投掷硬币的次数变成合计5次。
-- ●受到让自身基本分变成500以下的伤害。
function c19162134.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●把等级不同的怪兽5只同时特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c19162134.spcon1)
	e2:SetOperation(c19162134.drop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(c19162134.spcon2)
	e3:SetOperation(c19162134.drop2)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(c19162134.btcon1)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(c19162134.btcon2)
	c:RegisterEffect(e5)
	-- ●连锁5以上把卡的效果发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_FZONE)
	-- 设置该连续效果的操作函数为aux.chainreg，用于在每次效果发动（进入连锁）时给此卡记录一个标记，表明此卡在连锁发生前已在场上，供后续“连锁5以上”的判定使用。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e6=e2:Clone()
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetCondition(c19162134.chcon1)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EVENT_CHAIN_SOLVING)
	e7:SetCondition(c19162134.chcon2)
	c:RegisterEffect(e7)
	-- ●掷骰子的次数以及投掷硬币的次数变成合计5次。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_TOSS_COIN)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetOperation(c19162134.tossop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_TOSS_DICE)
	e9:SetOperation(c19162134.diceop)
	c:RegisterEffect(e9)
	local ea=e2:Clone()
	ea:SetCode(EVENT_DAMAGE)
	ea:SetCondition(c19162134.damcon1)
	c:RegisterEffect(ea)
	local eb=e3:Clone()
	eb:SetCode(EVENT_DAMAGE)
	eb:SetCondition(c19162134.damcon2)
	c:RegisterEffect(eb)
end
-- 过滤函数：判断怪兽c是否由玩家tp召唤或特殊召唤（IsSummonPlayer），用于筛选同时特殊召唤成功的怪兽中属于哪位玩家。
function c19162134.spfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 特殊召唤成功时点条件：本组同时特殊召唤成功的怪兽数量恰好为5，其中至少1只由tp玩家召唤，且5只怪兽的等级种类数为5（即等级各不相同）。满足时tp玩家完成“等级不同的怪兽5只同时特殊召唤”的条件。
function c19162134.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==5 and eg:IsExists(c19162134.spfilter,1,nil,tp) and eg:GetClassCount(Card.GetLevel)==5
end
-- 特殊召唤成功时点条件：本组同时特殊召唤成功的怪兽数量恰好为5，其中至少1只由对方（1-tp）玩家召唤，且5只怪兽的等级种类数为5。满足时对方玩家完成“等级不同的怪兽5只同时特殊召唤”的条件。
function c19162134.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==5 and eg:IsExists(c19162134.spfilter,1,nil,1-tp) and eg:GetClassCount(Card.GetLevel)==5
end
-- tp方条件达成后的处理：展示本卡动画，随后让tp玩家从卡组抽2张卡。
function c19162134.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示卡号为19162134的卡片动画，提示“娱乐决斗”的抽卡效果正在处理。
	Duel.Hint(HINT_CARD,0,19162134)
	-- 让tp玩家以效果原因（REASON_EFFECT）抽2张卡。
	Duel.Draw(tp,2,REASON_EFFECT)
end
-- 对方条件达成后的处理：展示本卡动画，随后让对方玩家从卡组抽2张卡。
function c19162134.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示卡号为19162134的卡片动画，提示“娱乐决斗”的抽卡效果正在处理。
	Duel.Hint(HINT_CARD,0,19162134)
	-- 让对方玩家（1-tp）以效果原因抽2张卡。
	Duel.Draw(1-tp,2,REASON_EFFECT)
end
-- 伤害计算后，统计tp方怪兽的战斗次数：若攻击者为对方则改取攻击对象，得到本次战斗中tp方控制的那只怪兽，为其累加1次战斗标记；当该怪兽累计战斗次数达到5时，tp方达成“自身1只怪兽进行5次战斗”的条件。
function c19162134.btcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击对象（被攻击怪兽）。
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(19162134,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_END,0,1)
		return a:GetFlagEffect(19162134)==5
	else return false end
end
-- 伤害计算后，统计对方（1-tp）怪兽的战斗次数：若攻击者为tp方则改取攻击对象，得到本次战斗中对方控制的那只怪兽，为其累加1次战斗标记；当该怪兽累计战斗次数达到5时，对方达成“自身1只怪兽进行5次战斗”的条件。
function c19162134.btcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的攻击对象（被攻击怪兽）。
	local d=Duel.GetAttackTarget()
	if a:IsControler(tp) then a,d=d,a end
	if a then
		a:RegisterFlagEffect(19162134,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_END,0,1)
		return a:GetFlagEffect(19162134)==5
	else return false end
end
-- 连锁处理时，判断tp方是否达成“连锁5以上把卡的效果发动”：本次连锁由tp方发动、当前连锁数≥5，且本卡在连锁发生前已在场上。满足则tp方完成该条件。
function c19162134.chcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：连锁的发动者为tp（rp==tp），当前连锁数不低于5，并且本卡带有FLAG_ID_CHAINING标记（表示本卡在连锁开始前已在场上）。
	return rp==tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 连锁处理时，判断对方是否达成“连锁5以上把卡的效果发动”：本次连锁由对方发动、当前连锁数≥5，且本卡在连锁发生前已在场上。满足则对方完成该条件。
function c19162134.chcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：连锁的发动者为对方（rp==1-tp），当前连锁数不低于5，并且本卡带有FLAG_ID_CHAINING标记。
	return rp==1-tp and Duel.GetCurrentChain()>=5 and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 投掷硬币结果产生后的累计处理：根据抛硬币的玩家，在该场地卡上累计该玩家的投掷次数；当某玩家累计（硬币+骰子）次数达到5且本回合尚未用此条件抽过牌时，让该玩家抽2张，并标记其已抽过牌。
function c19162134.tossop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp then
		for i=1,ev do
			c:RegisterFlagEffect(19162135,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	else
		for i=1,ev do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
	if c:GetFlagEffect(19162135)>=5 and c:GetFlagEffect(19162137)==0 then
		c19162134.drop1(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162137,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if c:GetFlagEffect(19162136)>=5 and c:GetFlagEffect(19162138)==0 then
		c19162134.drop2(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162138,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 掷骰子结果产生后的累计处理：ev低位/高位分别包含双方掷骰子次数，按ep归属累计到对应玩家的总投掷次数（与硬币次数共用同一计数）；达到5次且未抽过牌时让该玩家抽2张，并标记已抽。
function c19162134.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct1=bit.band(ev,0xffff)
	local ct2=bit.rshift(ev,16)
	if ep==tp then
		for i=1,ct1 do
			c:RegisterFlagEffect(19162135,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		for i=1,ct2 do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	else
		for i=1,ct2 do
			c:RegisterFlagEffect(19162135,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		for i=1,ct1 do
			c:RegisterFlagEffect(19162136,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
	if c:GetFlagEffect(19162135)>=5 and c:GetFlagEffect(19162137)==0 then
		c19162134.drop1(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162137,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	if c:GetFlagEffect(19162136)>=5 and c:GetFlagEffect(19162138)==0 then
		c19162134.drop2(e,tp,eg,ep,ev,re,r,rp)
		c:RegisterFlagEffect(19162138,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 伤害发生时的条件判断：受到伤害的是tp玩家，且伤害后tp的LP在1~500之间（即变成500以下但不为0），满足“受到让自身基本分变成500以下的伤害”的条件。
function c19162134.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：本次伤害的受害者是tp（ep==tp），并且伤害处理后tp的LP小于等于500且大于0。
	return ep==tp and Duel.GetLP(tp)<=500 and Duel.GetLP(tp)>0
end
-- 伤害发生时的条件判断：受到伤害的是对方（1-tp），且伤害后对方LP在1~500之间，满足“受到让自身基本分变成500以下的伤害”的条件。
function c19162134.damcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 条件为：本次伤害的受害者是对方（ep==1-tp），并且伤害处理后对方LP小于等于500且大于0。
	return ep==1-tp and Duel.GetLP(1-tp)<=500 and Duel.GetLP(1-tp)>0
end
