--超魔導師－ブラック・マジシャンズ
-- 效果：
-- 「黑魔术师」或「黑魔术少女」＋魔法师族怪兽
-- ①：1回合1次，魔法·陷阱卡的效果发动的场合才能发动。自己抽1张。那张抽到的卡是魔法·陷阱卡的场合，可以再把那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
-- ②：这张卡被破坏的场合才能发动。「黑魔术师」「黑魔术少女」各1只从自己的手卡·卡组·墓地特殊召唤。
function c50237654.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「超魔导师-黑魔术师徒」添加融合召唤手续：以「黑魔术师」或「黑魔术少女」其中1只作为卡号素材，加上1只魔法师族怪兽作为融合素材，从而进行融合召唤。
	aux.AddFusionProcCodeFun(c,{46986414,38033121},aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),1,true,true)
	-- ①：1回合1次，魔法·陷阱卡的效果发动的场合才能发动。自己抽1张。那张抽到的卡是魔法·陷阱卡的场合，可以再把那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
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
	-- ②：这张卡被破坏的场合才能发动。「黑魔术师」「黑魔术少女」各1只从自己的手卡·卡组·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c50237654.sptg)
	e2:SetOperation(c50237654.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检测当前连锁中发动的效果是否为魔法·陷阱卡的效果（即由魔法·陷阱卡的发动所触发）。
function c50237654.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①发动时的目标处理：确认自己可以抽1张卡，并登记抽卡操作信息（抽卡数量为1）。
function c50237654.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查玩家tp是否可以抽1张卡；若不能，则不能发动该效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 向系统登记本次效果将进行抽卡的操作信息：玩家tp抽1张卡，用于后续连锁检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的解决处理：自己抽1张；若抽到的卡是魔法·陷阱卡且可以盖放，则询问玩家是否盖放；若盖放且该卡是速攻魔法或陷阱，则赋予该卡在盖放回合即可发动的状态。
function c50237654.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 以效果原因让玩家tp抽1张卡；若抽卡成功（返回非0）才继续后续处理。
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 获取刚才抽到的那张卡（即最近一次卡片操作实际操作过的卡组中的第一张）。
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsType(TYPE_SPELL+TYPE_TRAP) and dc:IsSSetable()
			-- 当抽到的卡是魔法·陷阱卡且可以盖放时，询问玩家“是否把那张卡盖放？”；若玩家选否则不盖放。
			and Duel.SelectYesNo(tp,aux.Stringid(50237654,0)) then  --"是否把那张卡盖放？"
			-- 中断当前效果链的处理，使之后的盖放处理视为不同时处理，避免错时点。
			Duel.BreakEffect()
			-- 尝试将抽到的那张卡盖放到玩家tp自己的场上；如果盖放失败（返回0）则终止本次后续处理。
			if Duel.SSet(tp,dc,tp,false)==0 then return end
			if dc:IsType(TYPE_QUICKPLAY) then
				-- 把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(50237654,2))  --"适用「超魔导师-黑魔术师徒」的效果来发动"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1)
			end
			if dc:IsType(TYPE_TRAP) then
				-- 把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
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
-- 过滤函数spfilter1：用于选择「黑魔术师」（卡号46986414），要求该卡能够被特殊召唤，并且自己的手牌·卡组·墓地中存在可特殊召唤的「黑魔术少女」（spfilter2），以确保两只都能凑齐。
function c50237654.spfilter1(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认在手牌·卡组·墓地存在至少1只满足spfilter2的「黑魔术少女」（不包括已选择的c），作为第二只特殊召唤对象。
		and Duel.IsExistingMatchingCard(c50237654.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤函数spfilter2：用于选择「黑魔术少女」（卡号38033121），要求该卡能够被特殊召唤。
function c50237654.spfilter2(c,e,tp)
	return c:IsCode(38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：自己的手牌·卡组·墓地中存在「黑魔术师」和「黑魔术少女」各1只且都可特殊召唤，主要怪兽区空格数大于1，且当前不受「青眼精灵龙」效果影响（不能同时特殊召唤2只以上怪兽），满足这些条件才能发动。
function c50237654.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足spfilter1的「黑魔术师」（即存在可特殊召唤的黑魔术师且同时有对应的黑魔术少女可特殊召唤）。
	if chk==0 then return Duel.IsExistingMatchingCard(c50237654.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己主要怪兽区的可用空格数必须大于1，以保证可以同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 登记本次效果的特殊召唤操作信息：从自己的手牌·卡组·墓地特殊召唤2只怪兽（不取对象，处理时再选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的解决处理：首先再次确认未受「青眼精灵龙」限制且主要怪兽区至少2个空格；然后分别选择1只「黑魔术师」和1只「黑魔术少女」，将两者合并后同时以表侧表示特殊召唤到自己的场上。
function c50237654.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时检查主要怪兽区空格数；若少于2个则无法同时特殊召唤2只，整个处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，让玩家选择第一只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·卡组·墓地选择1只满足spfilter1的「黑魔术师」（排除受王家长眠之谷影响的卡），作为特殊召唤的第一只怪兽。
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50237654.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 显示“请选择要特殊召唤的卡”的选择提示，让玩家选择第二只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·卡组·墓地选择1只满足spfilter2的「黑魔术少女」（排除已选择的第一只怪兽，并排除王家长眠之谷影响），作为特殊召唤的第二只怪兽。
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50237654.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	if g1:GetCount()==2 then
		-- 将合并后的g1（包含两只怪兽）以表侧表示特殊召唤到玩家tp的场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
