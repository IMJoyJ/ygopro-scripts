--一か八か
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己基本分比对方少的场合才能发动。自己卡组最上面的卡给双方确认，等级是1星或者8星的怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，对方可以从以下效果选1个适用。
-- ●这张卡的控制者基本分变成1000。
-- ●从这张卡的控制者来看的对方基本分回复到变成8000。
function c74202664.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己基本分比对方少的场合才能发动。自己卡组最上面的卡给双方确认，等级是1星或者8星的怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，对方可以从以下效果选1个适用。●这张卡的控制者基本分变成1000。●从这张卡的控制者来看的对方基本分回复到变成8000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,74202664+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c74202664.condition)
	e1:SetTarget(c74202664.target)
	e1:SetOperation(c74202664.activate)
	c:RegisterEffect(e1)
end
-- ①效果的发动条件：检查自己当前基本分是否比对方少。
function c74202664.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方当前基本分是否严格低于对方当前基本分。
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- ①效果的目标处理函数：检查自己卡组是否有卡且存在可加入手卡的卡或在有空位时可特殊召唤。
function c74202664.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有的卡片组。
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	-- 发动条件检查：确认自己卡组至少有1张卡，且怪兽区有空位。
	if chk==0 then return #g>0 and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查在怪兽区有空位时己方是否可以特殊召唤且未受烈焰侠特殊召唤限制影响。
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		or g:IsExists(Card.IsAbleToHand,1,nil)) end
end
-- ①效果的处理函数：确认自己卡组最上面的卡，若为1星或8星怪兽则加入手卡或特殊召唤，否则让对方选择适用其中1个基本分调整效果（或什么都不做）。
function c74202664.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有的卡片组。
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g<=0 then return end
	-- 向双方确认自己卡组最上面的1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上面的1张卡。
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if tc:IsType(TYPE_MONSTER) and (tc:IsLevel(1) or tc:IsLevel(8)) then
		-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if not tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0) then return end
		-- 若确认的怪兽可加入手卡，且无法特殊召唤、没有怪兽区空位或玩家选择加入手卡时进入加入手卡分支。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 禁用洗卡检测以避免误洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将确认的1星或8星怪兽以效果加入自己手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 手动洗切己方的手卡。
			Duel.ShuffleHand(tp)
		else
			-- 禁用洗卡检测以避免误洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将确认的1星或8星怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 检查己方当前基本分是否不等于1000（以判定对方是否可选「控制者基本分变成1000」）。
		local b1=Duel.GetLP(tp)~=1000
		-- 检查对方是否受到「伤害变回复」效果的影响。
		local ea=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_DAMAGE)
		-- 检查对方是否受到「回复变伤害」效果的影响。
		local eb=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_RECOVER)
		-- 检查对方基本分是否低于8000且能够实际进行回复操作。
		local b2=Duel.GetLP(1-tp)<8000 and (ea or not eb)
		local b3=true
		local off=0
		local ops={}
		local opval={}
		off=1
		if b1 then
			ops[off]=aux.Stringid(74202664,0)  --"「赌一赌八」控制者基本分变成1000"
			opval[off-1]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(74202664,1)  --"「赌一赌八」控制者的对方基本分回复到8000"
			opval[off-1]=2
			off=off+1
		end
		if b3 then
			ops[off]=aux.Stringid(74202664,2)  --"什么都不做"
			opval[off-1]=3
			off=off+1
		end
		-- 让对方从可用选项中选择要适用的效果编号。
		local op=Duel.SelectOption(1-tp,table.unpack(ops))
		if opval[op]==1 then
			-- 若对方选择选项1，将己方（控制者）的基本分设置为1000。
			Duel.SetLP(tp,1000)
		elseif opval[op]==2 then
			-- 若对方选择选项2，让对方回复至8000基本分（回复量为8000减去当前基本分）。
			Duel.Recover(1-tp,8000-Duel.GetLP(1-tp),REASON_EFFECT)
		else return end
	end
end
