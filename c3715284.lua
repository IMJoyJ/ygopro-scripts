--機皇兵廠オブリガード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把「机皇兵厂 助奏」以外的2只「机皇兵」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。这个回合的结束阶段，给与对方为自己场上的「机皇」怪兽数量×100伤害。
function c3715284.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡破坏，从卡组把「机皇兵厂 助奏」以外的2只「机皇兵」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3715284,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,3715284)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c3715284.sptg)
	e1:SetOperation(c3715284.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。这个回合的结束阶段，给与对方为自己场上的「机皇」怪兽数量×100伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3715284,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3715284+100)
	e2:SetOperation(c3715284.regop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测卡组中是否存在满足条件的「机皇兵」怪兽（不包括自身）且可特殊召唤。
function c3715284.spfilter(c,e,tp)
	return c:IsSetCard(0x6013) and not c:IsCode(3715284) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的条件判断，检测是否满足特殊召唤的条件。
function c3715284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家场上是否有足够的怪兽区域（大于1）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测卡组中是否存在至少2张满足条件的「机皇兵」怪兽。
		and Duel.IsExistingMatchingCard(c3715284.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置操作信息，表示将要破坏此卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将要从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作。
function c3715284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测此卡是否还在场上且成功破坏。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择2张满足条件的「机皇兵」怪兽。
		local g=Duel.SelectMatchingCard(tp,c3715284.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的2张怪兽以守备表示特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 设置一个永续效果，使自己在本回合不能特殊召唤非机械族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3715284.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数，禁止召唤非机械族怪兽。
function c3715284.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 设置一个诱发效果，在结束阶段发动伤害效果。
function c3715284.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置一个持续效果，在结束阶段发动伤害效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c3715284.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于检测场上正面表示的「机皇」怪兽数量。
function c3715284.damfilter(c)
	return c:IsSetCard(0x13) and c:IsFaceup()
end
-- 效果处理函数，计算伤害并造成伤害。
function c3715284.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计场上正面表示的「机皇」怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c3715284.damfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示发动此卡的动画。
	Duel.Hint(HINT_CARD,0,3715284)
	-- 给与对方自己场上的「机皇」怪兽数量×100的伤害。
	Duel.Damage(1-tp,ct*100,REASON_EFFECT)
end
