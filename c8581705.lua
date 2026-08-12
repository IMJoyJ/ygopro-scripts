--インフェルノクインデーモン
-- 效果：
-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏。只要这张卡在场上存在，在每1个回合的准备阶段指定自己场上1只名称中含有「恶魔」字样的怪兽，被指定的怪兽到结束阶段为止，攻击力上升1000点。
function c8581705.initial_effect(c)
	-- 这张卡的控制者在自己的每1个准备阶段支付500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c8581705.mtcon)
	e1:SetOperation(c8581705.mtop)
	c:RegisterEffect(e1)
	-- 当这张卡成为对方所控制的卡的效果对象时，在效果处理时掷1次骰子，若掷出2或5，则使此效果无效并将其破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DICE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c8581705.disop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，在每1个回合的准备阶段指定自己场上1只名称中含有「恶魔」字样的怪兽，被指定的怪兽到结束阶段为止，攻击力上升1000点。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8581705,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c8581705.atktg)
	e3:SetOperation(c8581705.atkop)
	c:RegisterEffect(e3)
end
-- 维持基本分效果的条件函数：检查当前是否为自己的回合
function c8581705.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 维持基本分效果的操作函数：尝试支付500基本分，若无法支付或选择不支付（在有万魔殿时代替）则破坏该卡
function c8581705.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分，或者是否受到「万魔殿-恶魔的巢窟-」的效果影响
	if Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 如果玩家不受「万魔殿-恶魔的巢窟-」的效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或者玩家选择不适用「万魔殿-恶魔的巢窟-」的代替支付效果
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 玩家支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 作为无法支付维持代价的惩罚，破坏这张卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 掷骰子无效效果的操作函数：在连锁处理时，若此卡被对方卡片效果选为对象，则掷骰子，若为2或5则无效并破坏该卡
function c8581705.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理中连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 若对象不存在、对象不包含此卡、或者该连锁效果无法被无效，则不进行处理
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	-- 玩家掷1次骰子
	local dc=Duel.TossDice(tp,1)
	if dc~=2 and dc~=5 then return end
	-- 如果成功使该效果无效，且该卡在场上与效果相关联
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 破坏该效果的来源卡片
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示且卡名含有「恶魔」的怪兽
function c8581705.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 攻击力上升效果的目标选择函数：在准备阶段选择场上1只表侧表示的「恶魔」怪兽作为对象
function c8581705.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c8581705.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合过滤条件的「恶魔」怪兽作为效果对象
	Duel.SelectTarget(tp,c8581705.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 攻击力上升效果的操作函数：使选择的怪兽攻击力上升1000点，持续到回合结束
function c8581705.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 被指定的怪兽到结束阶段为止，攻击力上升1000点。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
