--ジェノサイドキングデーモン
-- 效果：
-- 这张卡仅当自己场上存在名称中含有「恶魔」字样的怪兽卡时才能进行召唤·反转召唤。这张卡的控制者在自己的每1个准备阶段支付800基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏。被这张卡战斗破坏的效果怪兽的效果无效化。
function c35975813.initial_effect(c)
	-- 这张卡仅当自己场上存在名称中含有「恶魔」字样的怪兽卡时才能进行召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c35975813.excon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在自己的每1个准备阶段支付800基本分
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c35975813.mtcon)
	e3:SetOperation(c35975813.mtop)
	c:RegisterEffect(e3)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCategory(CATEGORY_DICE)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c35975813.disop)
	c:RegisterEffect(e4)
	-- 被这张卡战斗破坏的效果怪兽的效果无效化
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(c35975813.disop2)
	c:RegisterEffect(e5)
end
-- 过滤函数，检查场上是否存在名称中含有「恶魔」字样的怪兽卡
function c35975813.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 判断是否满足召唤条件，即自己场上不存在名称中含有「恶魔」字样的怪兽卡
function c35975813.excon(e)
	-- 当自己场上不存在名称中含有「恶魔」字样的怪兽卡时，返回true以阻止召唤
	return not Duel.IsExistingMatchingCard(c35975813.exfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断是否为自己的准备阶段
function c35975813.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当轮到自己准备阶段时，返回true以触发效果
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段支付基本分或因其他效果不支付基本分的处理逻辑
function c35975813.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付800基本分或是否受到特定效果影响
	if Duel.CheckLPCost(tp,800) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 判断玩家是否未受到特定效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 若未受到特定效果影响，则询问是否使用该效果不支付基本分
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 支付800基本分
			Duel.PayLPCost(tp,800)
		end
	else
		-- 若无法支付基本分，则将自身破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 连锁处理时判断是否为对方效果作用于自身，若满足条件则投掷骰子并根据结果无效效果并破坏目标卡
function c35975813.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若目标卡片组为空、不包含自身或该连锁不可无效，则返回false
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 投掷一次骰子
	local dc=Duel.TossDice(tp,1)
	if dc~=2 and dc~=5 then return end
	-- 若成功无效效果且目标卡存在，则将其破坏
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 战斗破坏效果怪兽时，使该怪兽效果无效
function c35975813.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if tc and tc:IsType(TYPE_EFFECT) and tc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 使被战斗破坏的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e1)
		-- 使被战斗破坏的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e2)
	end
end
