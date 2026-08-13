--TG ラッシュ・ライノ
-- 效果：
-- 这张卡攻击的场合，伤害步骤内这张卡的攻击力上升400。场上存在的这张卡被破坏送去墓地的回合的结束阶段时，可以从自己卡组把「科技属 突冲犀牛」以外的1只名字带有「科技属」的怪兽加入手卡。
function c36687247.initial_effect(c)
	-- 这张卡攻击的场合，伤害步骤内这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c36687247.atcon)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被破坏送去墓地的回合的结束阶段时，可以从自己卡组把「科技属 突冲犀牛」以外的1只名字带有「科技属」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c36687247.regop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的发动条件：当前阶段为伤害步骤或伤害计算时，且效果持有者（这张卡）正是攻击怪兽。
function c36687247.atcon(e)
	-- 获取当前所处的阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否为伤害步骤或伤害计算时，并且效果持有者（这张卡）是攻击怪兽。
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and e:GetHandler()==Duel.GetAttacker()
end
-- 此卡从场上被破坏送去墓地时，如果满足条件，就给自己在墓地注册一个结束阶段发动的检索效果，用于后续检索「科技属」怪兽。
function c36687247.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 场上存在的这张卡被破坏送去墓地的回合的结束阶段时，可以从自己卡组把「科技属 突冲犀牛」以外的1只名字带有「科技属」的怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(36687247,0))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c36687247.thtg)
		e1:SetOperation(c36687247.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索的过滤条件：卡名带有「科技属」、不是「科技属 突冲犀牛」自身、是怪兽卡且能够加入手卡。
function c36687247.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(36687247) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件和操作信息设置：自己卡组存在符合条件的怪兽时才能发动；发动时设置将1张卡从卡组加入手卡的操作信息。
function c36687247.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己卡组是否存在至少1只符合过滤条件的「科技属」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36687247.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为：从卡组把1张卡加入手卡，用于后续处理与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1只符合条件的「科技属」怪兽加入手卡，并向对方展示确认。
function c36687247.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张符合过滤条件的「科技属」怪兽。
	local g=Duel.SelectMatchingCard(tp,c36687247.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（此处即自己手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
