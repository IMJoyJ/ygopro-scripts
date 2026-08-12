--ギアギアギア XG
-- 效果：
-- 3星怪兽×3
-- 自己场上的机械族怪兽进行战斗的战斗步骤时，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的卡的效果直到那次伤害步骤结束时无效，直到那次伤害步骤结束时对方不能把魔法·陷阱·效果怪兽的效果发动。此外，这张卡从场上离开时，可以从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡加入手卡。
function c19891310.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用3星怪兽作为素材进行叠放
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 自己场上的机械族怪兽进行战斗的战斗步骤时，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的卡的效果直到那次伤害步骤结束时无效，直到那次伤害步骤结束时对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19891310,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c19891310.condition)
	e1:SetCost(c19891310.cost)
	e1:SetOperation(c19891310.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡从场上离开时，可以从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19891310,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c19891310.thcon)
	e2:SetTarget(c19891310.thtg)
	e2:SetOperation(c19891310.thop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：己方场上机械族怪兽参与战斗
function c19891310.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local bt=Duel.GetAttacker()
	if bt and bt:IsControler(tp) then return bt:IsRace(RACE_MACHINE) end
	-- 获取当前被攻击怪兽
	bt=Duel.GetAttackTarget()
	return bt and bt:IsControler(tp) and bt:IsRace(RACE_MACHINE)
end
-- 支付发动费用：从场上移除1个超量素材
function c19891310.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动效果：使对方场上所有卡的效果无效并禁止对方发动魔法·陷阱·效果怪兽的效果
function c19891310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个使对方场上所有卡的效果无效的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
	-- 创建一个禁止对方发动魔法·陷阱·效果怪兽效果的效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c19891310.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制对方发动效果的函数，用于判断是否为魔法·陷阱·效果怪兽的效果
function c19891310.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
-- 判断是否满足发动条件：该卡从场上离开时
function c19891310.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤函数，用于筛选墓地中的齿轮齿轮卡
function c19891310.thfilter(c)
	return c:IsSetCard(0x72) and c:IsAbleToHand()
end
-- 设置发动时的选择目标：从墓地中选择一张齿轮齿轮卡
function c19891310.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19891310.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c19891310.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地卡作为目标
	local g=Duel.SelectTarget(tp,c19891310.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息，表示将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果：将选择的卡加入手牌并确认给对方
function c19891310.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
