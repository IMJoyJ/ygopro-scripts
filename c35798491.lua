--ダークビショップデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当自己场上存在的名称中含有「恶魔」字样的怪兽卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
function c35798491.initial_effect(c)
	-- 效果原文内容：这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c35798491.mtcon)
	e1:SetOperation(c35798491.mtop)
	c:RegisterEffect(e1)
	-- 效果原文内容：当自己场上存在的名称中含有「恶魔」字样的怪兽卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c35798491.disop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为当前回合玩家的准备阶段
function c35798491.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面作用：处理准备阶段支付基本分或因特殊效果免支付并可能破坏自身
function c35798491.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家是否能支付500基本分或是否受特定效果影响
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 规则层面作用：检查玩家是否未受特定效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 规则层面作用：询问玩家是否使用特定效果免支付基本分
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 规则层面作用：支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 规则层面作用：因无法支付基本分而破坏自身
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 规则层面作用：定义过滤函数，用于判断目标怪兽是否为场上正面表示的恶魔族怪兽
function c35798491.filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x45)
end
-- 规则层面作用：连锁处理时判断是否满足无效条件并执行骰子判定与效果无效及破坏操作
function c35798491.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 规则层面作用：获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 规则层面作用：判断目标卡片组是否包含符合条件的恶魔族怪兽且连锁可被无效
	if not tg or not tg:IsExists(c35798491.filter,1,nil,tp) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 规则层面作用：投掷一次骰子
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==3 or dc==6 then
		-- 规则层面作用：使连锁效果无效并判断原卡是否仍然存在于场上
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 规则层面作用：破坏连锁效果的原卡
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
