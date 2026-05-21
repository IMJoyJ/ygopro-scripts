--シャドウナイトデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付900基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。这张卡对对方玩家造成的战斗伤害减半。
function c9603356.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付900基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c9603356.mtcon)
	e1:SetOperation(c9603356.mtop)
	c:RegisterEffect(e1)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出3，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c9603356.disop)
	c:RegisterEffect(e2)
	-- 这张卡对对方玩家造成的战斗伤害减半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	-- 设置战斗伤害改变效果：将此卡对对方玩家造成的战斗伤害减半
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 维护代价效果的条件函数
function c9603356.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 维护代价效果的操作函数
function c9603356.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付900基本分，或者是否受到「万魔殿-恶魔的巢窟-」的效果影响
	if Duel.CheckLPCost(tp,900) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 如果玩家不受「万魔殿-恶魔的巢窟-」的效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或者玩家选择不适用「万魔殿-恶魔的巢窟-」的效果来免除支付
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 玩家支付900基本分
			Duel.PayLPCost(tp,900)
		end
	else
		-- 因无法支付维护代价而将这张卡破坏
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 骰子无效效果的操作函数
function c9603356.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象卡片组不存在、不包含此卡，或该连锁效果无法被无效，则不进行后续处理
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 让控制者投掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc~=3 then return end
	-- 若成功使该效果无效，且该卡与效果存在关联，则进行后续破坏处理
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 将该效果的卡破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
