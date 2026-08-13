--地獄の暴走召喚
-- 效果：
-- ①：对方场上有表侧表示怪兽存在，自己场上只有攻击力1500以下的怪兽1只特殊召唤时才能发动。那只特殊召唤的怪兽的同名怪兽从自己的手卡·卡组·墓地尽可能攻击表示特殊召唤，对方选自身场上1只表侧表示怪兽，那只怪兽的同名怪兽从自身的手卡·卡组·墓地尽可能特殊召唤。
function c12247206.initial_effect(c)
	-- ①：对方场上有表侧表示怪兽存在，自己场上只有攻击力1500以下的怪兽1只特殊召唤时才能发动。那只特殊召唤的怪兽的同名怪兽从自己的手卡·卡组·墓地尽可能攻击表示特殊召唤，对方选自身场上1只表侧表示怪兽，那只怪兽的同名怪兽从自身的手卡·卡组·墓地尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12247206.condition)
	e1:SetTarget(c12247206.target)
	e1:SetOperation(c12247206.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：本次特殊召唤成功的怪兽只有1只，且该怪兽属于己方、位于场上、表侧表示、攻击力1500以下；同时对方场上有表侧表示怪兽存在。
function c12247206.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp)
		and tc:IsFaceup() and tc:IsAttackBelow(1500)
		-- 检查对方场上有表侧表示怪兽存在（以己方视角检索对方怪兽区至少1张表侧表示怪兽）。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤函数：判断卡c与特殊召唤的怪兽tc是否为同一卡名（当前卡号相同，可应对卡名被效果改变的场合）。
function c12247206.nfilter(c,tc)
	return c:IsCode(tc:GetCode())
end
-- 过滤函数：从己方手卡·卡组·墓地中选择与tc同名，且可以被己方效果特殊召唤为表侧攻击表示的怪兽。
function c12247206.spfilter1(c,tc,e,tp)
	return c12247206.nfilter(c,tc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 过滤函数：从对方手卡·卡组·墓地中选择与tc同名，且可以被对方效果特殊召唤的怪兽（不指定表示形式，默认表侧表示）。
function c12247206.spfilter2(c,tc,e,tp)
	return c12247206.nfilter(c,tc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标处理：先确认己方怪兽区有空位且存在可特殊召唤的同名怪兽；然后将本次特殊召唤的怪兽tc与效果建立关联，并把候选特殊召唤组登记到操作信息中，以便后续处理。
function c12247206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		-- 从己方的手卡·卡组·墓地中检索所有与特殊召唤怪兽同名且满足表侧攻击表示特殊召唤条件的怪兽，用于判定是否有卡可特殊召唤。
		local g=Duel.GetMatchingGroup(c12247206.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
		-- 判定发动是否合法：己方主要怪兽区存在空格，且至少有一张符合条件的同名怪兽可以特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
	end
	tc:CreateEffectRelation(e)
	-- 从己方的手卡·卡组·墓地中再次检索所有符合条件的同名怪兽，作为后续特殊召唤处理时的候选组。
	local g=Duel.GetMatchingGroup(c12247206.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
	-- 设置操作信息：本次效果包含特殊召唤，候选组为g，数量为g的数量，目标玩家为双方，涉及区域为手牌·卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),PLAYER_ALL,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 辅助函数：依次将组g中的每张卡以指定表示形式进行特殊召唤（使用SpecialSummonStep逐步处理，最终由SpecialSummonComplete统一完成并触发时点）。
function c12247206.sp(g,tp,pos)
	local sc=g:GetFirst()
	while sc do
		-- 将单张卡sc以效果e、sumtype=0、特殊召唤到己方场上，表示形式为pos，作为连续特殊召唤的一步。
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,pos)
		sc=g:GetNext()
	end
end
-- 效果处理：先计算己方可用的怪兽区空格并受青眼精灵龙等限制，从手卡·卡组·墓地中挑选与特殊召唤怪兽同名的怪兽尽可能表侧攻击表示特殊召唤（超出空格数则己方选择）；然后让对方选择自己场上1只表侧表示怪兽，计算对方可用空格后，从对方手卡·卡组·墓地中挑选其同名怪兽尽可能特殊召唤（超出则对方选择）；最后完成整个特殊召唤。
function c12247206.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 获取己方主要怪兽区内可用的空格数量，用于限制这次最多能特殊召唤的怪兽数量。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft1>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
	-- 从己方手卡·卡组·墓地中检索所有与tc同名且可表侧攻击表示特殊召唤的怪兽，并通过NecroValleyFilter排除因王家长眠之谷效果而不能从墓地特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12247206.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
	if ft1>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if g:GetCount()<=ft1 then
			c12247206.sp(g,tp,POS_FACEUP_ATTACK)
		else
			-- 向己方玩家发送选择提示信息，要求其从候选怪兽中选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local fg=g:Select(tp,ft1,ft1,nil)
			c12247206.sp(fg,tp,POS_FACEUP_ATTACK)
		end
	end
	-- 获取对方主要怪兽区内可用的空格数量，用于限制对方在这次效果中最多能特殊召唤的怪兽数量。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
	-- 向对方玩家发送选择提示信息，要求其选择自身场上的1只表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让对方玩家从自己场上选择1张表侧表示怪兽，作为后续检索同名怪兽的对照对象。
	local sg=Duel.SelectMatchingCard(1-tp,Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,1,nil)
	if ft2>0 and sg:GetCount()>0 then
		-- 从对方的手卡·卡组·墓地中检索所有与所选怪兽同名且可被对方特殊召唤的怪兽，并排除因王家长眠之谷效果而不能从墓地特殊召唤的卡。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12247206.spfilter2),1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,sg:GetFirst(),e,1-tp)
		if g2:GetCount()>0 then
			if g2:GetCount()<=ft2 then
				c12247206.sp(g2,1-tp,POS_FACEUP)
			else
				-- 向对方玩家发送选择提示信息，要求其在可用的怪兽区范围内选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local fg=g2:Select(1-tp,ft2,ft2,nil)
				c12247206.sp(fg,1-tp,POS_FACEUP)
			end
		end
	end
	-- 完成所有步骤累积的特殊召唤，正式将已逐步特殊召唤的怪兽全部特殊召唤成功，并触发对应的特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
