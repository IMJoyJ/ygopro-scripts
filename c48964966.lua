--アテナ
-- 效果：
-- ①：1回合1次，把「雅典娜」以外的自己场上1只表侧表示的天使族怪兽送去墓地，以「雅典娜」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
function c48964966.initial_effect(c)
	-- ①：1回合1次，把「雅典娜」以外的自己场上1只表侧表示的天使族怪兽送去墓地，以「雅典娜」以外的自己墓地1只天使族怪兽为对象才能发动。那只天使族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48964966,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c48964966.cost)
	e1:SetTarget(c48964966.target)
	e1:SetOperation(c48964966.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c48964966.condition2)
	e2:SetTarget(c48964966.target2)
	e2:SetOperation(c48964966.operation2)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c48964966.condition2)
	e3:SetTarget(c48964966.target2)
	e3:SetOperation(c48964966.operation2)
	c:RegisterEffect(e3)
	-- ②：这张卡已在怪兽区域存在的状态，这张卡以外的天使族怪兽召唤·反转召唤·特殊召唤的场合发动。给与对方600伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48964966,1))  --"伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetCondition(c48964966.condition2)
	e4:SetTarget(c48964966.target2)
	e4:SetOperation(c48964966.operation2)
	c:RegisterEffect(e4)
end
-- 作为代价的怪兽筛选条件：必须为表侧表示的天使族怪兽、卡名不是「雅典娜」、可以作为代价送去墓地；且当前已有空余主要怪兽区，或该怪兽位于主要怪兽区（送墓后可空出位置用于后续特殊召唤）。
function c48964966.filter1(c,ft)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and not c:IsCode(48964966) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 发动代价处理：先计算可用主要怪兽区数量，确认存在可选的代价怪兽后，让玩家从自己场上选择1只满足filter1的表侧表示天使族怪兽，将其作为代价送去墓地。
function c48964966.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上主要怪兽区的可用空格数，用于判断支付代价后是否仍有（或能空出）特殊召唤的位置。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检测：在场上区域状态没有异常（ft>-1）且存在1只符合filter1的代价怪兽时，允许发动；即使当前空格为0，也能通过送墓位于主要怪兽区的怪兽腾出空格。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c48964966.filter1,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 发送选择提示消息，提示玩家选择要作为代价送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动玩家从自己场上选择1只符合filter1的怪兽，作为此效果的发动代价。
	local g=Duel.SelectMatchingCard(tp,c48964966.filter1,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将所选怪兽以“代价”这一理由送入墓地，完成①的cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤对象筛选：墓地中卡名不是「雅典娜」的天使族怪兽，并且该怪兽能够被当前效果以表侧表示特殊召唤（已确认满足苏生限制与召唤条件）。
function c48964966.filter2(c,e,sp)
	return c:IsRace(RACE_FAIRY) and not c:IsCode(48964966) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的取对象处理：确认墓地存在可取对象后，玩家选择1只不是「雅典娜」的天使族怪兽作为对象，并登记为特殊召唤的处理信息。
function c48964966.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48964966.filter2(chkc,e,tp) end
	-- 取对象检测：确认自己墓地存在1只满足filter2且可以作为效果对象的天使族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c48964966.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 发送选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽，并将其设为当前连锁的取对象卡（后续特殊召唤的对象）。
	local g=Duel.SelectTarget(tp,c48964966.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本连锁的操作信息：将特殊召唤1只怪兽及对象组写入连锁，供相关卡片的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：从连锁对象中取出之前选择的天使族怪兽，确认其仍与该效果相关且仍为天使族后，将其表侧表示特殊召唤到自己场上。
function c48964966.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡（即要特殊召唤的墓地天使族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FAIRY) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上；由于在选对象时已做过可召唤判定，这里按正常规则进行特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的触发条件：这次召唤·反转召唤·特殊召唤成功的怪兽组中不包含「雅典娜」自身，并且其中至少1只怪兽为天使族。
function c48964966.condition2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:FilterCount(Card.IsRace,nil,RACE_FAIRY)>0
end
-- ②诱发效果的发动准备：不进行选择，直接登记对象玩家为对方、伤害数值为600，并写入造成伤害的操作信息。
function c48964966.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁对象玩家设为对方玩家，表示伤害将给予对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁对象参数设为600，表示造成的伤害数值为600。
	Duel.SetTargetParam(600)
	-- 登记本次连锁操作将造成600点效果伤害（对象为对方玩家），供其他效果检测与应对。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- ②效果处理：从连锁信息中取得目标玩家与伤害数值，并对该玩家造成600点效果伤害。
function c48964966.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁登记的目标玩家和伤害参数，得到伤害对象与数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予对方玩家600点效果伤害，来源为效果（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
