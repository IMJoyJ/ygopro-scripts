--一か八か
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己基本分比对方少的场合才能发动。自己卡组最上面的卡给双方确认，等级是1星或者8星的怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，对方可以从以下效果选1个适用。
-- ●这张卡的控制者基本分变成1000。
-- ●从这张卡的控制者来看的对方基本分回复到变成8000。
function c74202664.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己基本分比对方少的场合才能发动。自己卡组最上面的卡给双方确认，等级是1星或者8星的怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，对方可以从以下效果选1个适用。●这张卡的控制者基本分变成1000。●从这张卡的控制者来看的对方基本分回复到变成8000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,74202664+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c74202664.condition)
	e1:SetTarget(c74202664.target)
	e1:SetOperation(c74202664.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：自己基本分比对方少
function c74202664.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己当前基本分是否小于对方当前基本分
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 定义发动准备（Target）函数：检查卡组是否有卡，以及是否能进行加入手卡或特殊召唤的操作
function c74202664.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	-- 检查卡组数量大于0，且自己场上有怪兽区域空位
	if chk==0 then return #g>0 and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤，且未受到无法特殊召唤的限制效果影响
		and Duel.IsPlayerCanSpecialSummon(tp) and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		or g:IsExists(Card.IsAbleToHand,1,nil)) end
end
-- 定义效果处理（Operation）函数：确认卡组最上方的卡，根据其等级和种类执行加入手卡、特殊召唤或由对方选择适用基本分变化效果
function c74202664.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g<=0 then return end
	-- 将自己卡组最上面的1张卡给双方确认
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上面的那张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if tc:IsType(TYPE_MONSTER) and (tc:IsLevel(1) or tc:IsLevel(8)) then
		-- 获取自己场上可用的怪兽区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if not tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0) then return end
		-- 若该卡能加入手卡，且（不能特殊召唤、无怪兽空位或玩家选择加入手卡），则执行加入手卡处理
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 使接下来的操作不触发系统自动洗牌检测
			Duel.DisableShuffleCheck()
			-- 将该卡因效果加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 手动洗切自己的手卡
			Duel.ShuffleHand(tp)
		else
			-- 使接下来的特殊召唤操作不触发系统自动洗牌检测
			Duel.DisableShuffleCheck()
			-- 将该卡在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 检查自己（这张卡的控制者）的基本分是否不等于1000（若不等于，则可以适用变成1000的效果）
		local b1=Duel.GetLP(tp)~=1000
		-- 检查对方（从控制者来看的对方）是否受到伤害变回复效果的影响
		local ea=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_DAMAGE)
		-- 检查对方（从控制者来看的对方）是否受到回复变伤害效果的影响
		local eb=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_REVERSE_RECOVER)
		-- 检查对方基本分是否小于8000，且回复效果不会变成伤害（确保回复到8000是可行的）
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
		-- 由对方玩家从可适用的效果选项中选择一个适用
		local op=Duel.SelectOption(1-tp,table.unpack(ops))
		if opval[op]==1 then
			-- 将这张卡的控制者（自己）的基本分变成1000
			Duel.SetLP(tp,1000)
		elseif opval[op]==2 then
			-- 使对方（从控制者来看的对方）基本分回复到变成8000（回复差值）
			Duel.Recover(1-tp,8000-Duel.GetLP(1-tp),REASON_EFFECT)
		else return end
	end
end
