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
-- 判断是否处于伤害步骤或伤害计算阶段且该卡为攻击卡
function c36687247.atcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前阶段为伤害步骤或伤害计算阶段且该卡为攻击卡则返回true
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and e:GetHandler()==Duel.GetAttacker()
end
-- 当此卡因破坏被送入墓地时，注册一个在结束阶段触发的效果
function c36687247.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- 检索满足条件的卡片组
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
-- 过滤函数，用于筛选名字带有「科技属」且不是自身、类型为怪兽、可以加入手牌的卡片
function c36687247.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(36687247) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置连锁操作信息，确定要处理的卡的数量和位置
function c36687247.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c36687247.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将要处理的卡为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，选择一张符合条件的卡加入手牌
function c36687247.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c36687247.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
