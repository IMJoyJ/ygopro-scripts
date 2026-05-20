--ヘルポーンデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。只要这张卡在场上存在，除这张卡的同名卡以外，对方不能攻击自己场上名称中含有「恶魔」字样的怪兽。
function c73219648.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c73219648.mtcon)
	e1:SetOperation(c73219648.mtop)
	c:RegisterEffect(e1)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c73219648.disop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，除这张卡的同名卡以外，对方不能攻击自己场上名称中含有「恶魔」字样的怪兽。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c73219648.atktg)
	c:RegisterEffect(e3)
end
-- 准备阶段维持基本分效果的条件函数
function c73219648.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持基本分效果的处理函数
function c73219648.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分，或者是否适用「万魔殿-恶魔的巢窟-」的效果
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 若玩家未受到「万魔殿-恶魔的巢窟-」的效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或者玩家选择不适用「万魔殿-恶魔的巢窟-」的效果来免除支付基本分
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 让玩家支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 因无法支付维持代价而将此卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 成为对方效果对象时掷骰子无效并破坏的处理函数
function c73219648.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象不存在、对象不包含此卡、或该连锁效果无法被无效，则不进行处理
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 让控制者掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc~=3 then return end
	-- 若成功使该效果无效，且发动效果的卡仍与该效果有关联
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 将发动该效果的卡破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 过滤不能被选择为攻击对象的怪兽（自己场上表侧表示的除同名卡以外的「恶魔」怪兽）
function c73219648.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x45) and not c:IsCode(73219648)
end
