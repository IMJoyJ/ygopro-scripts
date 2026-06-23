--プリズンクインデーモン
-- 效果：
-- 这张卡的控制者在每次自己的准备阶段支付1000基本分。场上有「万魔殿-恶魔的巢窟-」存在，这张卡在墓地存在的场合，每次自己的准备阶段把场上存在的1只4星以下的恶魔族怪兽的攻击力直到结束阶段时上升1000。
function c52248570.initial_effect(c)
	-- 记录此卡与「万魔殿-恶魔的巢窟-」之间的关联
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
-- 判断是否为当前回合玩家触发效果
function c52248570.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家触发效果
	return Duel.GetTurnPlayer()==tp
end
-- 处理支付基本分或因「万魔殿-恶魔的巢窟-」效果不支付基本分的情况
function c52248570.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付1000基本分或是否受「万魔殿-恶魔的巢窟-」影响
	if Duel.CheckLPCost(tp,1000) or Duel.IsPlayerAffectedByEffect(tp,94585852) then
		-- 判断是否未受「万魔殿-恶魔的巢窟-」影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 询问玩家是否使用「万魔殿-恶魔的巢窟-」效果不支付基本分
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 支付1000基本分
			Duel.PayLPCost(tp,1000)
		end
	else
		-- 若无法支付基本分则破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 判断是否为当前回合玩家且场地存在「万魔殿-恶魔的巢窟-」
function c52248570.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家且场地存在「万魔殿-恶魔的巢窟-」
	return Duel.GetTurnPlayer()==tp and Duel.IsEnvironment(94585852)
end
-- 筛选场上表侧表示、等级4以下且为恶魔族的怪兽
function c52248570.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_FIEND)
end
-- 选择符合条件的场上怪兽作为目标
function c52248570.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52248570.filter(chkc) end
	if chk==0 then return true end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的怪兽为目标
	Duel.SelectTarget(tp,c52248570.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽攻击力上升1000点直到结束阶段
function c52248570.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍存在于连锁中且场地存在「万魔殿-恶魔的巢窟-」
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsEnvironment(94585852) then return end
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽赋予攻击力上升1000的效果，持续到结束阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
