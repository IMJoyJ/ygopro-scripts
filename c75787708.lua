--四天の龍 オッドアイズ・ペンデュラム・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把场上的怪兽的效果发动。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：灵摆召唤的这张卡得到以下效果。
-- ●只要自己的灵摆区域有2张卡存在，这张卡的攻击力上升那个灵摆刻度差×300。
-- ●这张卡的战斗发生的对对方的战斗伤害变成2倍。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡加入手卡。这张卡被对方破坏的场合，可以再把这张卡特殊召唤。
local s,id,o=GetID()
-- 注册“四天之龙 异色眼灵摆龙”的卡片效果：包含启用灵摆怪兽属性、灵摆效果①（破坏检索灵摆怪兽及限制效果发动）、怪兽效果①（刻度差上升攻击力与双倍伤害）、怪兽效果②（被破坏加手/特召）以及全局灵摆召唤监测效果。
function s.initial_effect(c)
	-- 启用灵摆怪兽的灵摆属性（注册灵摆召唤和作为灵摆卡发动等规则支持）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把场上的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：灵摆召唤的这张卡得到以下效果。●只要自己的灵摆区域有2张卡存在，这张卡的攻击力上升那个灵摆刻度差×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ①：灵摆召唤的这张卡得到以下效果。●这张卡的战斗发生的对对方的战斗伤害变成2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e3:SetCondition(s.atkcon)
	-- 设置战斗伤害变化效果的数值：对对方造成的战斗伤害变成2倍。
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- 这个卡名的②的怪兽效果1回合只能使用1次。②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡加入手卡。这张卡被对方破坏的场合，可以再把这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon2)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。这个回合自己只要灵摆召唤不成功，不能把场上的怪兽的效果发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS_G_P)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册给系统，用于监测是否有玩家进行灵摆召唤。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 灵摆召唤成功时的全局监听回调函数：为灵摆召唤成功的玩家注册一个持续到回合结束的标识效果。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为进行灵摆召唤的玩家注册一个在回合结束时重置的标记效果（表示该玩家在本回合已成功进行过灵摆召唤）。
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：检索满足攻击力在1500以下、是灵摆怪兽且可以加入手牌条件的卡片。
function s.thfilter(c)
	return c:IsAttackBelow(1500)
		and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果①的发动准备（Target）：检查自身是否可以破坏以及卡组是否存在满足条件的灵摆怪兽；设置破坏自身以及从卡组检索卡片加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动判定：检查自身是否可以被破坏，并且卡组中是否存在至少1张攻击力1500以下的灵摆怪兽。
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将这张灵摆区域 of 卡作为要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果①的效果处理（Operation）：将这张灵摆卡破坏，从卡组选择1只攻击力1500以下的灵摆怪兽加入手牌；之后清除该回合灵摆召唤成功的标记，并注册一个直到回合结束前“只要灵摆召唤不成功，就不能发动场上怪兽效果”的限制效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否仍与连锁相关，并尝试以效果原因破坏该卡。若成功破坏则继续执行后续处理。
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 给玩家显示“选择要加入手牌的卡”的系统提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张符合过滤条件（攻击力1500以下的灵摆怪兽）的卡片。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 以效果原因将选中的卡片送入玩家手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手牌的卡片向对方玩家进行确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 重置/清除当前玩家在该回合成功进行过灵摆召唤的的标记效果（用于重新判定后续是否灵摆召唤成功）。
	Duel.ResetFlagEffect(tp,id)
	-- 这个回合自己只要灵摆召唤不成功，不能把场上的怪兽的效果发动。/①：灵摆召唤的这张卡得到以下效果。●只要自己的灵摆区域有2张卡存在，这张卡的攻击力上升那个灵摆刻度差×300。/②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡加入手卡。这张卡被对方破坏的场合，可以再把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.discon)
	e1:SetValue(s.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能发动场上怪兽效果的限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动限制 of 条件判断：当前玩家本回合还没有成功进行过灵摆召唤时，该限制效果生效。
function s.discon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前玩家在全局环境下未注册有灵摆召唤成功的标识（即本回合还未成功进行灵摆召唤）。
	return Duel.GetFlagEffect(tp,id)==0
end
-- 效果发动的限制类型：限制场上怪兽区域怪兽效果的发动。
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 攻击力上升与战斗伤害变化效果的生效条件：这张卡是灵摆召唤的场合。
function s.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 攻击力上升数值计算：检查己方两个灵摆区域的卡片，若两张卡均存在且灵摆刻度不同，则上升两者的灵摆刻度差的绝对值乘以300的数值。
function s.atkval(e,c)
	-- 获取己方左侧和右侧灵摆区域的卡片。
	local l,r=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,0),Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1)
	if not (l and r) then return 0 end
	local ls,rs=l:GetCurrentScale(),r:GetCurrentScale()
	if ls==rs then return 0 end
	return math.abs(rs-ls)*300
end
-- 怪兽效果②的发动条件：怪兽区域的这张卡被战斗或效果破坏。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 怪兽效果②的发动准备（Target）：确认该卡是否可以加入手牌；若是因为对方的效果或与对方怪兽战斗破坏的，则将效果类别设置为包含特殊召唤，并设为标签值1；设置回收及可能特殊召唤的操作信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetLabel(0)
	end
	-- 设置操作信息：将这张被破坏的卡作为加入手牌的对象。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息：将这张卡作为从墓地离开的对象。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 怪兽效果②的效果处理（Operation）：在不受“王家长眠之谷”影响的情况下将此卡加入手牌。如果该卡被对方破坏且己方场上有空位、该卡可特殊召唤，则可以由玩家选择是否将此卡特殊召唤。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否仍与连锁相关，并在不受“王家长眠之谷”影响的情况下执行后续效果。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果原因将此卡加入持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手牌的这张卡向对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
		if e:GetLabel()==1
			-- 检查己方主要怪兽区域是否还有可用的空位。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 让玩家选择是否发动将这张卡特殊召唤的效果。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断效果处理，使后续的特殊召唤处理与加入手牌处理不视为同时进行。
			Duel.BreakEffect()
			-- 将这张卡以表侧表示特殊召唤到发动者的场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
