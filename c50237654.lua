--超魔導師－ブラック・マジシャンズ
-- 效果：
-- 「黑魔术师」或「黑魔术少女」＋魔法师族怪兽
-- ①：1回合1次，魔法·陷阱卡的效果发动的场合才能发动。自己抽1张。那张抽到的卡是魔法·陷阱卡的场合，可以再把那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
-- ②：这张卡被破坏的场合才能发动。「黑魔术师」「黑魔术少女」各1只从自己的手卡·卡组·墓地特殊召唤。
function c50237654.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用「黑魔术师」或「黑魔术少女」与1只魔法师族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,{46986414,38033121},aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),1,true,true)
	-- 效果原文：①：1回合1次，魔法·陷阱卡的效果发动的场合才能发动。自己抽1张。那张抽到的卡是魔法·陷阱卡的场合，可以再把那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50237654,1))  --"抽1张卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c50237654.drcon)
	e1:SetTarget(c50237654.drtg)
	e1:SetOperation(c50237654.drop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被破坏的场合才能发动。「黑魔术师」「黑魔术少女」各1只从自己的手卡·卡组·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c50237654.sptg)
	e2:SetOperation(c50237654.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为魔法或陷阱卡的效果发动
function c50237654.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置抽卡和盖放魔陷的操作信息
function c50237654.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡后盖放魔陷的逻辑
function c50237654.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行抽卡动作
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 获取抽到的卡片
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsType(TYPE_SPELL+TYPE_TRAP) and dc:IsSSetable()
			-- 询问玩家是否盖放抽到的卡
			and Duel.SelectYesNo(tp,aux.Stringid(50237654,0)) then  --"是否把那张卡盖放？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 尝试将卡片盖放到场上
			if Duel.SSet(tp,dc,tp,false)==0 then return end
			if dc:IsType(TYPE_QUICKPLAY) then
				-- 为速攻魔法卡添加在盖放回合可发动的效果
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(50237654,2))  --"适用「超魔导师-黑魔术师徒」的效果来发动"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1)
			end
			if dc:IsType(TYPE_TRAP) then
				-- 为陷阱卡添加在盖放回合可发动的效果
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(50237654,2))  --"适用「超魔导师-黑魔术师徒」的效果来发动"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1)
			end
		end
	end
end
-- 筛选可以特殊召唤的「黑魔术师」
function c50237654.spfilter1(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在符合条件的「黑魔术少女」
		and Duel.IsExistingMatchingCard(c50237654.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 筛选可以特殊召唤的「黑魔术少女」
function c50237654.spfilter2(c,e,tp)
	return c:IsCode(38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标和条件
function c50237654.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在符合条件的「黑魔术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c50237654.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查玩家场上是否有足够的召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理特殊召唤的逻辑
function c50237654.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否还有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的「黑魔术师」
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50237654.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的「黑魔术少女」
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50237654.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()==2 then
		-- 将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
