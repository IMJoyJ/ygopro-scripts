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
-- 该过滤函数用于检索可特殊召唤的「机皇兵」怪兽：要求卡组中的卡属于「机皇兵」系列（0x6013）、卡名不是「机皇兵厂 助奏」自身，并且能够以表侧守备表示特殊召唤。
function c3715284.spfilter(c,e,tp)
	return c:IsSetCard(0x6013) and not c:IsCode(3715284) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件判定：自己主要阶段且场上可用怪兽区大于1，且己方不受【青眼精灵龙】的“不能同时特殊召唤2只以上怪兽”效果影响，且卡组中存在至少2只满足spfilter的「机皇兵」怪兽。
function c3715284.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少2个可用的怪兽区域（因为要特殊召唤2只怪兽）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组中是否存在至少2只满足特殊召唤条件的「机皇兵」怪兽（已排除本卡）。
		and Duel.IsExistingMatchingCard(c3715284.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设定操作信息：本效果会以这张卡自身为对象进行破坏，数量为1，为后续的“破坏”处理及相关时点检测提供信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设定操作信息：本效果会从卡组特殊召唤2只怪兽，但具体对象在效果处理时才确定，因此targets设为nil，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ①效果处理：先确认这张卡仍与效果关联并成功被效果破坏，同时场上剩余怪兽区不少于2且没有【青眼精灵龙】的限制效果，然后从卡组选2只「机皇兵」怪兽守备表示特殊召唤。
function c3715284.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定发动效果处理的这张卡仍与当前连锁关联，并且能够被效果破坏（实际执行破坏并返回破坏成功数>0）。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 给玩家弹出选择提示：“请选择要特殊召唤的卡”，用于后续的选择操作。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组选择2只满足spfilter的「机皇兵」怪兽（不取对象，在效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,c3715284.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的2只「机皇兵」怪兽以表侧守备表示特殊召唤到己方场上（不检查召唤条件、不限制苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3715284.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“只能特殊召唤机械族怪兽”的自肃效果注册到场上，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定：若将要特殊召唤的怪兽不是机械族（RACE_MACHINE），则不允许特殊召唤。
function c3715284.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- ②效果发动时，在结束阶段注册一个延迟的伤害效果；该效果在结束阶段只处理一次，并且本回合结束阶段重置。
function c3715284.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，给与对方为自己场上的「机皇」怪兽数量×100伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c3715284.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段触发伤害的延迟效果注册到场上，使其在结束阶段生效。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害计算用的过滤条件：统计自己场上表侧表示且属于「机皇」（0x13）系列的怪兽。
function c3715284.damfilter(c)
	return c:IsSetCard(0x13) and c:IsFaceup()
end
-- 结束阶段处理伤害：计算符合条件的「机皇」怪兽数量，若为0则直接结束；否则给对方造成数量×100的效果伤害，并展示本卡卡图动画。
function c3715284.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上满足damfilter（表侧表示且属于「机皇」系列）的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c3715284.damfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 向双方展示本卡的卡图动画，提示即将处理本卡的伤害效果。
	Duel.Hint(HINT_CARD,0,3715284)
	-- 给对方造成自己场上「机皇」怪兽数量×100点的效果伤害。
	Duel.Damage(1-tp,ct*100,REASON_EFFECT)
end
