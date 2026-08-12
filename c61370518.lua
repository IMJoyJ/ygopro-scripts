--迅雷の魔王－スカル・デーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
function c61370518.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c61370518.mtcon)
	e1:SetOperation(c61370518.mtop)
	c:RegisterEffect(e1)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c61370518.disop)
	c:RegisterEffect(e2)
end
-- 准备阶段维持代价的判定条件函数
function c61370518.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持代价的执行函数，处理支付500基本分或因无法支付而破坏
function c61370518.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分，或者是否受到「万魔殿-恶魔的巢窟-」的效果影响
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 如果玩家没有受到「万魔殿-恶魔的巢窟-」的效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或者玩家选择不适用「万魔殿-恶魔的巢窟-」的效果
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 玩家支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 因无法支付维持代价而将该卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 成为对方卡片效果对象时掷骰子无效并破坏的效果处理函数
function c61370518.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象不存在、不包含这张卡，或者该连锁无法被无效，则不进行处理
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 让玩家掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==3 or dc==6 then
		-- 如果成功使该效果无效，且发动效果的卡仍存在于关联位置
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 将发动效果的卡破坏
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
