--魔降雷
local s,id,o=GetID()
-- 定义卡片初始效果，包括攻击力改变和破坏效果以及将墓地卡片加入手牌的效果。
function s.initial_effect(c)
	-- 创建并注册一个激活类效果，描述信息从id为0的字符串获取，效果类别为攻击力改变与破坏，类型为启动型，属性为可以取对象且可以在伤害步骤发动，代码为自由连锁，限制每回合一次，目标由s.target函数指定，操作由s.activate函数执行。
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
	-- 创建并注册一个起动类效果，描述信息从id为1的字符串获取，效果类别为将卡片加入手牌，类型为起动型，属性为可以取对象，发动范围为墓地，限制每回合一次，代价由aux.bfgcost函数指定，目标由s.thtg函数指定，操作由s.thop函数执行。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置将这张卡除外的效果的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于筛选表侧表示且属于0x45系列（地属性）的卡片。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x45)
end
-- 定义目标选择函数，用于选择表侧表示的地属性怪兽作为效果的目标。如果正在检查目标有效性则返回true或false，否则提示玩家选择一张符合条件的卡片。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否存在满足s.filter函数的、位于对方怪兽区域的卡片。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求其选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从场上选择一张符合s.filter条件的卡片作为目标。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义一个过滤函数，用于筛选攻击力低于指定值的表侧表示怪兽。
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetBaseAttack()<atk
end
-- 定义效果激活函数，实现攻击力提升和破坏效果。首先获取目标卡片，如果目标卡片与连锁相关且为表侧表示，则赋予其攻击力提升效果，然后调整场地信息。接着判断目标卡片是否具有反转更新效果，以及是否存在攻击力低于目标卡片攻击力的怪兽，并询问玩家是否要破坏这些怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 创建单张效果，提升目标怪兽的攻击力600点。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 立刻刷新场地信息。
		Duel.AdjustAll()
		local atk=tc:GetAttack()
		-- 检查目标怪兽是否具有反转更新效果，以及是否存在攻击力低于目标怪兽攻击力的表侧表示怪兽。
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
			-- 询问玩家是否要破坏攻击力低于目标卡片攻击力的怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果的处理。
			Duel.BreakEffect()
			-- 获取所有满足s.desfilter函数的、位于对方怪兽区域的卡片。
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
			-- 以效果为理由，破坏sg组内的卡片。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 定义一个过滤函数，用于筛选攻击力为2500、种族为恶魔族、等级为6且可以加入手牌的卡片。
function s.thfilter(c)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsAbleToHand()
end
-- 定义目标选择函数，用于从墓地选择符合条件的卡片。如果正在检查目标有效性则返回true或false，否则提示玩家选择一张符合条件的卡片。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否存在满足s.thfilter函数的、位于对方墓地的卡片。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，要求其选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择一张符合s.thfilter条件的卡片作为目标。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前处理连锁的操作信息，表示将选定的卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果操作函数，实现将墓地卡片加入手牌的效果。首先获取目标卡片，如果目标卡片与连锁相关，则将其送入持有者的手牌并确认卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 以效果为理由，将目标卡片送入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认所操作的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
