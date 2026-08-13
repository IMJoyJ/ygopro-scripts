--鉄のハンス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「铁骑士」特殊召唤。这个效果的处理时场地区域没有「急流山的金宫」存在的场合，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ②：场地区域有「急流山的金宫」存在的场合，这张卡的攻击力上升自己场上的「铁骑士」数量×1000。
function c41916534.initial_effect(c)
	-- 将卡号72283691（「急流山的金宫」）登记到铁汉斯的效果文案记载列表中，以便系统识别这张卡的效果文字提及了该卡名。
	aux.AddCodeList(c,72283691)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只「铁骑士」特殊召唤。这个效果的处理时场地区域没有「急流山的金宫」存在的场合，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41916534,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,41916534)
	e1:SetTarget(c41916534.sptg)
	e1:SetOperation(c41916534.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：场地区域有「急流山的金宫」存在的场合，这张卡的攻击力上升自己场上的「铁骑士」数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(c41916534.atkcon)
	e4:SetValue(c41916534.value)
	c:RegisterEffect(e4)
end
-- 特殊召唤的候选卡过滤条件：必须是「铁骑士」（卡号73405179），且能够被当前效果特殊召唤（满足召唤手续/苏生限制）。
function c41916534.filter(c,e,tp)
	return c:IsCode(73405179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：这张卡召唤·反转召唤·特殊召唤成功时，检查自己主要怪兽区是否存在可用空格，且卡组中是否存在满足条件的「铁骑士」，满足才可发动。
function c41916534.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的合法条件之一：自己场上（主要怪兽区）有空余区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动的合法条件之二：卡组中存在至少1张「铁骑士」（满足filter过滤条件）可供特殊召唤。
		and Duel.IsExistingMatchingCard(c41916534.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向连锁系统登记操作信息：本次效果处理将进行1次从卡组的特殊召唤，对象卡数量为1，检索区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：若有空位则从卡组选1只「铁骑士」特殊召唤；然后检查场地区域是否有「急流山的金宫」，若没有则给发动玩家附加直到回合结束不能从额外卡组特殊召唤怪兽的自肃。
function c41916534.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行特殊召唤前再次确认自己主要怪兽区仍有空位（若处理时没有空位则不特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示“请选择要特殊召唤的卡”的提示消息，引导玩家选择特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选出1张满足filter条件的「铁骑士」作为本次特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,c41916534.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「铁骑士」以表侧表示特殊召唤到发动玩家场上（不额外检查召唤条件/苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 效果处理时检查场地区域是否没有「急流山的金宫」；若不存在则进入后续自肃处理。
	if not Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) then
		-- 这个效果的处理时场地区域没有「急流山的金宫」存在的场合，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。②：场地区域有「急流山的金宫」存在的场合，这张卡的攻击力上升自己场上的「铁骑士」数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c41916534.splimit)
		-- 将自肃效果（不能从额外卡组特殊召唤怪兽）注册到当前决斗中，作用对象为发动玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃限制的对象判定：只要被特殊召唤的怪兽位于额外卡组（LOCATION_EXTRA）即禁止特殊召唤。
function c41916534.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果攻击力上升的适用条件判定：场地区域存在「急流山的金宫」时，此攻击力上升效果适用。
function c41916534.atkcon(e)
	-- 检查当前场地区域是否存在卡号72283691的「急流山的金宫」（任意一方场地均可），返回布尔值。
	return Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
end
-- 统计攻击力上升数值时使用的卡片过滤条件：表侧表示且卡号为73405179的「铁骑士」。
function c41916534.atkfilter(c)
	return c:IsFaceup() and c:IsCode(73405179)
end
-- 计算攻击力上升量：自己场上满足atkfilter条件的「铁骑士」数量乘以1000，作为攻击力上升值。
function c41916534.value(e,c)
	-- 实际返回攻击力上升数值：自己场上的表侧表示「铁骑士」数量 × 1000。
	return Duel.GetMatchingGroupCount(c41916534.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*1000
end
