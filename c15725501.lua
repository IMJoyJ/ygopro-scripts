--魔降雷
local s,id,o=GetID()
-- 注册卡牌的两个效果： activate 和 ignition effect
function s.initial_effect(c)
	-- 此卡发动时，选择1只自己场上的表侧表示的「魔降」怪兽，那个攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡在墓地时，可以发动1次。选择1张自己墓地的攻击力2500、种族为恶魔、等级为6的怪兽加入手牌。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 支付1张除外的自身作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示且属于魔降卡组的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 选择目标：选择自己场上的1只表侧表示的魔降怪兽作为效果对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否满足选择目标的条件：自己场上是否存在至少1只表侧表示的魔降怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行选择目标操作：选择自己场上的1只表侧表示的魔降怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤条件：表侧表示且基础攻击力低于指定值的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- 效果处理：使目标怪兽攻击力上升600，并根据条件决定是否破坏对方场上攻击力低于该怪兽的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 给目标怪兽添加一个攻击力上升600的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 刷新场上所有卡片的状态信息
		Duel.AdjustAll()
		local atk=tc:GetAttack()
		-- 检查是否满足破坏条件：目标怪兽未受到反转效果影响，且对方场上有攻击力低于该怪兽的怪兽
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
			-- 询问玩家是否发动破坏效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理流程
			Duel.BreakEffect()
			-- 获取所有满足破坏条件的怪兽组
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
			-- 将满足条件的怪兽全部破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 过滤条件：攻击力为2500、种族为恶魔、等级为6且可以加入手牌的怪兽
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsAbleToHand()
end
-- 选择目标：选择自己墓地的1张符合条件的怪兽作为效果对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否满足选择目标的条件：自己墓地是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择目标：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择目标操作：选择自己墓地的1张符合条件的怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选择的怪兽送去手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选择的怪兽加入手牌并确认对方看到该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认该怪兽已加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
