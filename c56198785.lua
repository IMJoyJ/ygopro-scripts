--背護衛
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从墓地的特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。
-- ②：这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
function c56198785.initial_effect(c)
	-- ①：这张卡从墓地的特殊召唤成功的场合，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56198785,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,56198785)
	e1:SetCondition(c56198785.indcon)
	e1:SetTarget(c56198785.indtg)
	e1:SetOperation(c56198785.indop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c56198785.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56198785,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,56198786)
	e3:SetCondition(c56198785.thcon)
	e3:SetTarget(c56198785.thtg)
	e3:SetOperation(c56198785.thop)
	c:RegisterEffect(e3)
end
-- 判定此卡是否从墓地特殊召唤成功
function c56198785.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 效果①的发动准备与对象选择
function c56198785.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只怪兽作为效果的对象
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：使目标怪兽在这个回合获得战斗与效果破坏抗性
function c56198785.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
-- 在这张卡被除外时，给自身注册一个持续到回合结束的Flag，用于标记该卡在当前回合被除外
function c56198785.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(56198785,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡在当前回合是否被除外过
function c56198785.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56198785)>0
end
-- 效果②的发动准备，确认自身是否能加入手卡并设置操作信息
function c56198785.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将这张卡加入手卡
function c56198785.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
