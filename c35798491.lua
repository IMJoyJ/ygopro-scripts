--ダークビショップデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当自己场上存在的名称中含有「恶魔」字样的怪兽卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
function c35798491.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c35798491.mtcon)
	e1:SetOperation(c35798491.mtop)
	c:RegisterEffect(e1)
	-- 当自己场上存在的名称中含有「恶魔」字样的怪兽卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出1·3·6，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c35798491.disop)
	c:RegisterEffect(e2)
end
-- 触发条件判断：仅在控制者的准备阶段才处理该效果。
function c35798491.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家是这张卡的控制者，则条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段的处理：若能支付500基本分或适用「万魔殿-恶魔的巢窟-」的效果则进行支付选择；若不能支付则将此卡破坏。
function c35798491.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付500基本分，或是否因「万魔殿-恶魔的巢窟-」的效果可以不支付基本分。
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 当没有「万魔殿-恶魔的巢窟-」的效果适用时，直接进入需要支付基本分的分支。
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 若有「万魔殿-恶魔的巢窟-」的效果，则询问玩家是否使用该效果免去支付；若选择不使用，则仍需支付500基本分。
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 支付500基本分作为维持这张卡的控制代价。
			Duel.PayLPCost(tp,500)
		end
	else
		-- 无法支付维持代价时，将这张卡以规则代价的方式破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 筛选符合条件的怪兽：位于我方怪兽区、表侧表示，且为名称中含有「恶魔」字段（0x45）的怪兽。
function c35798491.filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x45)
end
-- 连锁处理时的对应操作：当对方效果取对象且对象中有我方符合条件的「恶魔」怪兽时，掷骰子并可能无效该效果和破坏来源。
function c35798491.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中该效果取对象的所有卡片。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若存在取对象卡组、其中有我方符合条件的「恶魔」怪兽，并且该连锁可被无效，才继续处理。
	if not tg or not tg:IsExists(c35798491.filter,1,nil,tp) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 投掷1次骰子，得到1个1～6的点数。
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==3 or dc==6 then
		-- 若点数为1、3或6，则尝试无效该效果；若无效成功且效果来源卡仍与该效果关联，则继续破坏。
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 将被无效的效果的来源卡以效果原因破坏。
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
