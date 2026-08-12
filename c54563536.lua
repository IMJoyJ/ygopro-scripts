--マシンナーズ・リザーブレイク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，以自己场上1只「机甲」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1200。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在，自己的「机甲」怪兽战斗破坏对方怪兽时才能发动。这张卡加入手卡。
function c54563536.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地，以自己场上1只「机甲」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1200。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54563536,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,54563536)
	-- 设置效果在伤害步骤中，只有在伤害计算前才能发动（利用aux.dscon辅助函数过滤伤害计算后）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c54563536.atkcost)
	e1:SetTarget(c54563536.atktg)
	e1:SetOperation(c54563536.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己的「机甲」怪兽战斗破坏对方怪兽时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54563536,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,54563537)
	e2:SetCondition(c54563536.thcon)
	e2:SetTarget(c54563536.thtg)
	e2:SetOperation(c54563536.thop)
	c:RegisterEffect(e2)
end
-- 效果①的代价处理函数：把手卡·场上的这张卡送去墓地。
function c54563536.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤自己场上表侧表示的「机甲」怪兽。
function c54563536.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x36)
end
-- 效果①的对象选择与发动准备函数。
function c54563536.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c54563536.atkfilter(chkc) end
	-- 检查自己场上是否存在可选的表侧表示「机甲」怪兽（若在场上发动则排除自身）。
	if chk==0 then return Duel.IsExistingTarget(c54563536.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「机甲」怪兽作为效果对象。
	Duel.SelectTarget(tp,c54563536.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理函数：使选择的怪兽攻击力上升。
function c54563536.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升1200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1200)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定：自己的「机甲」怪兽战斗破坏对方怪兽。
function c54563536.thcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0x36) and rc:IsControler(tp)
end
-- 效果②的发动准备与可行性检查。
function c54563536.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将此卡加入手卡的效果处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数：将此卡加入手卡。
function c54563536.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
