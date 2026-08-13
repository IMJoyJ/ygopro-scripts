--凶導の聖獣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的墓地·除外状态的1只怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只额外卡组的怪兽或者卡组的「教导」怪兽送去墓地，作为对象的怪兽特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡的初始效果函数：为卡注册①效果，该效果为发动型效果（魔法卡发动），取对象，一回合一次，目标选择函数为s.target，处理函数为s.activate。
function s.initial_effect(c)
	-- 对应①效果：“①：以自己的墓地·除外状态的1只怪兽为对象才能发动。把持有那只怪兽的攻击力以上的攻击力的1只额外卡组的怪兽或者卡组的「教导」怪兽送去墓地，作为对象的怪兽特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤对象的过滤器：选择自己墓地·除外状态的1只怪兽，该怪兽需表侧表示且能被效果特殊召唤，并且额外卡组或卡组存在至少1张可送去墓地的符合条件的卡（额外卡组怪兽或「教导」怪兽，攻击力不低于此怪兽）。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认存在至少1张可送去墓地的卡（额外卡组的怪兽或卡组的「教导」怪兽，攻击力不低于对象怪兽的攻击力），以确保效果处理时能完成送墓。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil,c:GetAttack())
end
-- 定义送去墓地的卡的过滤器：选择1张「教导」怪兽或额外卡组的怪兽（必须是怪兽卡），攻击力在指定攻击力以上，并且可以被送去墓地。
function s.tgfilter(c,atk)
	return (c:IsSetCard(0x145) or c:IsLocation(LOCATION_EXTRA)) and c:IsType(TYPE_MONSTER)
		and c:IsAttackAbove(atk) and c:IsAbleToGrave()
end
-- 目标选择与发动条件判定：指定对象时必须选择自己墓地·除外状态且满足spfilter的怪兽；发动时还需自己主要怪兽区有空位，并且存在至少1只满足条件的对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己的主要怪兽区有空位，用于后续特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 发动条件检查：自己墓地·除外状态存在至少1只满足spfilter条件的怪兽可以作为对象。
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作者展示提示文字“请选择要特殊召唤的卡”，用于选择对象时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地·除外状态选择1只满足spfilter条件的怪兽作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果包含将1张卡（从额外卡组或卡组）送去墓地的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
	-- 设置操作信息：本效果包含将对象怪兽特殊召唤的处理，g是已选定的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取回对象怪兽；若对象怪兽表侧表示且与连锁相关，则选择1张符合条件的卡送去墓地；送墓成功且对象怪兽不受王家长眠之谷影响时，将对象怪兽特殊召唤。之后，若该效果为发动效果，则给自己适用“不能从额外卡组把怪兽特殊召唤”的限制，持续到下次自己回合结束（持续时间根据当前回合归属决定）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽（墓地·除外状态的1只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		local atk=tc:GetAttack()
		-- 向操作者展示提示文字“请选择要送去墓地的卡”，用于选择送墓卡时的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从额外卡组或卡组选择1张满足tgfilter条件的卡（额外卡组怪兽或「教导」怪兽，攻击力不低于对象怪兽攻击力），准备送去墓地。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil,atk)
		local gc=g:GetFirst()
		-- 确认所选卡被效果成功送去墓地（且确实在墓地），并且对象怪兽不受王家长眠之谷影响时，才执行特殊召唤。
		if gc and Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(tc) then
			-- 将对象怪兽以表侧表示特殊召唤到自己的场上（不跳过召唤条件与苏生限制的检查）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 对应效果原文：“这张卡的发动后，直到下次的自己回合的结束时自己不能从额外卡组把怪兽特殊召唤。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))  --"「凶导的圣兽」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		-- 判断当前回合玩家是否就是效果发动者，以决定“不能从额外卡组特殊召唤”限制的生效时长：若当前是自己回合则持续到下一次自己的结束阶段；若当前是对方回合则持续到自己的结束阶段。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 将“不能从额外卡组把怪兽特殊召唤”的限制效果注册给发动者tp，使其在该期间内适用。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义限制效果的过滤条件：限制的怪兽为位于额外卡组的怪兽（即不能从额外卡组特殊召唤怪兽）。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
