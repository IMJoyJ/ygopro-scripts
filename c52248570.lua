--プリズンクインデーモン
-- 效果：
-- 这张卡的控制者在每次自己的准备阶段支付1000基本分。场上有「万魔殿-恶魔的巢窟-」存在，这张卡在墓地存在的场合，每次自己的准备阶段把场上存在的1只4星以下的恶魔族怪兽的攻击力直到结束阶段时上升1000。
function c52248570.initial_effect(c)
	-- 将卡号94585852（万魔殿-恶魔的巢窟-）登记到该卡的代码列表中，使此卡在规则上视为记载了该卡名。
	aux.AddCodeList(c,94585852)
	-- 这张卡的控制者在每次自己的准备阶段支付1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c52248570.mtcon)
	e1:SetOperation(c52248570.mtop)
	c:RegisterEffect(e1)
	-- 场上有「万魔殿-恶魔的巢窟-」存在，这张卡在墓地存在的场合，每次自己的准备阶段把场上存在的1只4星以下的恶魔族怪兽的攻击力直到结束阶段时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52248570,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c52248570.atkcon)
	e2:SetTarget(c52248570.atktg)
	e2:SetOperation(c52248570.atkop)
	c:RegisterEffect(e2)
end
-- 定义强制支付基本分效果的发动条件：仅在效果持有者自己的准备阶段且自己为回合玩家时满足。
function c52248570.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否就是效果的控制者，即“自己的准备阶段”这一条件。
	return Duel.GetTurnPlayer()==tp
end
-- 处理每次准备阶段必须支付的1000基本分：若能支付或受万魔殿效果影响则进入选择，否则支付；若不能或选择不支付则破坏此卡。
function c52248570.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否能支付1000LP，或是否处于「万魔殿-恶魔的巢窟-」的适用中而不必支付基本分。
	if Duel.CheckLPCost(tp,1000) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 若控制者不受「万魔殿-恶魔的巢窟-」的影响，则没有“不支付基本分”的替代选项，必须支付。
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 若控制者虽然受万魔殿影响，但选择不使用其效果来免除支付，此时仍需支付1000基本分。
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 实际支付1000基本分作为该卡每次准备阶段必须支付的维持代价。
			Duel.PayLPCost(tp,1000)
		end
	else
		-- 当无法支付或拒绝支付基本分时，以规则代价的方式将这张卡破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 定义墓地攻击力上升效果的发动条件：自己准备阶段且场上存在「万魔殿-恶魔的巢窟-」。
function c52248570.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前为控制者的准备阶段，并且场上存在卡号94585852的「万魔殿-恶魔的巢窟-」时，条件成立。
	return Duel.GetTurnPlayer()==tp and Duel.IsEnvironment(94585852)
end
-- 筛选对象怪兽的条件：表侧表示、等级4以下、种族为恶魔族的怪兽。
function c52248570.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FIEND)
end
-- 选择效果对象：从双方怪兽区选择1只满足条件的表侧表示4星以下恶魔族怪兽。
function c52248570.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52248570.filter(chkc) end
	if chk==0 then return true end
	-- 弹出“选择表侧表示的卡”的提示信息，引导玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 设定效果取对象，从双方怪兽区域中选择1只表侧表示、4星以下、恶魔族的怪兽作为攻击力上升的对象。
	Duel.SelectTarget(tp,c52248570.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理攻击力上升效果：若此卡仍与效果关联且万魔殿在场，则将对象怪兽的攻击力上升1000直到结束阶段。
function c52248570.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动效果时位于墓地的此卡已经离场或与效果失去联系，或者「万魔殿-恶魔的巢窟-」已不在场上，则本次效果处理不执行。
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsEnvironment(94585852) then return end
	-- 获取这个效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
