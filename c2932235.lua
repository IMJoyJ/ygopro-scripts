--サウザンド・アンブラル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组把1张「七皇的冀望乡」在自己的场地区域表侧表示放置。这个效果的发动后，直到下次的自己回合的结束时，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，超量怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个回合，自己的效果发生的对自己的效果伤害变成0。
local s,id,o=GetID()
-- 初始化这张卡的全部效果：登记记载卡名「七皇的冀望乡」，注册①的放置场地的诱发即时效果和②的墓地自我特殊召唤的诱发效果
function s.initial_effect(c)
	-- 登记这张卡上记载着卡名「七皇的冀望乡」（卡号39513225）
	aux.AddCodeList(c,39513225)
	-- ①：自己·对方回合，把手卡·场上的这张卡送去墓地才能发动。从手卡·卡组把1张「七皇的冀望乡」在自己的场地区域表侧表示放置。这个效果的发动后，直到下次的自己回合的结束时，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置场地"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.actcost)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	-- 注册「此卡已在墓地」的标记检测效果，用于②效果在同一连锁中正确判断这张卡是否在墓地存在
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ②：这张卡在墓地存在的状态，超量怪兽特殊召唤的场合才能发动。这张卡特殊召唤。这个回合，自己的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价：确认这张卡可以作为代价送去墓地，然后把这张卡送去墓地作为发动代价
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 放置场地卡的过滤器：未被禁止放置、是场地魔法卡、卡名为「七皇的冀望乡」且在自己场上满足唯一性限制
function s.pfilter(c,tp)
	return not c:IsForbidden() and c:IsType(TYPE_FIELD) and c:IsCode(39513225) and c:CheckUniqueOnField(tp)
end
-- ①效果的对象确认：检查自己的手卡·卡组是否存在可以放置到场地区域的「七皇的冀望乡」
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·卡组是否存在满足条件的「七皇的冀望乡」
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- ①效果的处理：让玩家选择1张「七皇的冀望乡」放置到场地区域，之后注册一个限制自己只能从额外卡组特殊召唤超量怪兽的效果，直到下次的自己回合结束
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选卡提示：请选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己的手卡·卡组选择1张满足条件的「七皇的冀望乡」
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 取得自己场地区域现有的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 场地区域已有卡的场合，把那张卡按规则送去墓地（场地卡的规则替换）
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使送去墓地和放置场地卡视为不同时处理
			Duel.BreakEffect()
		end
		-- 把选择的「七皇的冀望乡」在自己的场地区域表侧表示放置并立即适用其效果
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	-- 这个效果的发动后，直到下次的自己回合的结束时，自己不是超量怪兽不能从额外卡组特殊召唤。②：这张卡在墓地存在的状态，超量怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))  --"「上千阴影」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 判断当前是否是发动玩家的回合，以决定限制效果需要持续到自己回合结束还是下次自己回合结束
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	-- 把「不能从额外卡组特殊召唤超量怪兽以外怪兽」的限制效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：从额外卡组特殊召唤的怪兽只要不是超量怪兽就不能特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤器：表侧表示的超量怪兽，且其特殊召唤不是由这张卡自身送去墓地时登记的连锁效果引起的
function s.cfilter(c,se)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中存在超量怪兽（且非自身效果所致）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,se)
end
-- ②效果的对象确认：自己主要怪兽区域有空位且这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区域有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此连锁将把墓地的这张卡特殊召唤，供王家长眠之谷等效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：把墓地的这张卡特殊召唤，之后注册两个效果使这个回合自己受到的效果伤害变成0
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡从墓地以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己的效果发生的对自己的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「效果伤害数值变更为0」的效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不发生效果伤害」的效果注册给发动玩家
	Duel.RegisterEffect(e2,tp)
end
-- 伤害计算函数：如果是自己的效果对自己造成的效果伤害则变成0，否则维持原伤害数值
function s.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==e:GetHandlerPlayer() then return 0
	else return val end
end
