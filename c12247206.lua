--地獄の暴走召喚
-- 效果：
-- ①：对方场上有表侧表示怪兽存在，自己场上只有攻击力1500以下的怪兽1只特殊召唤时才能发动。那只特殊召唤的怪兽的同名怪兽从自己的手卡·卡组·墓地尽可能攻击表示特殊召唤，对方选自身场上1只表侧表示怪兽，那只怪兽的同名怪兽从自身的手卡·卡组·墓地尽可能特殊召唤。
function c12247206.initial_effect(c)
	-- ①：对方场上有表侧表示怪兽存在，自己场上只有攻击力1500以下的怪兽1只特殊召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c12247206.condition)
	e1:SetTarget(c12247206.target)
	e1:SetOperation(c12247206.activate)
	c:RegisterEffect(e1)
end
-- 效果条件判断函数，用于检测是否满足发动条件
function c12247206.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp)
		and tc:IsFaceup() and tc:IsAttackBelow(1500)
		-- 检查对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
-- 同名卡过滤器函数，用于判断卡是否与目标怪兽同名
function c12247206.nfilter(c,tc)
	return c:IsCode(tc:GetCode())
end
-- 特殊召唤过滤器函数1，用于筛选可以攻击表示特殊召唤的同名卡
function c12247206.spfilter1(c,tc,e,tp)
	return c12247206.nfilter(c,tc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 特殊召唤过滤器函数2，用于筛选可以特殊召唤的同名卡（无特定表示方向）
function c12247206.spfilter2(c,tc,e,tp)
	return c12247206.nfilter(c,tc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设定函数，用于设置效果处理时的目标卡
function c12247206.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		-- 获取满足条件的可特殊召唤卡组（手牌·卡组·墓地）
		local g=Duel.GetMatchingGroup(c12247206.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
		-- 判断是否满足发动条件：场上存在空位且有可特殊召唤的卡
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0
	end
	tc:CreateEffectRelation(e)
	-- 再次获取满足条件的可特殊召唤卡组（手牌·卡组·墓地）
	local g=Duel.GetMatchingGroup(c12247206.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
	-- 设置连锁操作信息，告知后续处理将特殊召唤指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),PLAYER_ALL,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤执行函数，用于批量特殊召唤卡
function c12247206.sp(g,tp,pos)
	local sc=g:GetFirst()
	while sc do
		-- 执行单张卡的特殊召唤步骤，设置为攻击表示
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,pos)
		sc=g:GetNext()
	end
end
-- 效果发动处理函数，用于执行效果的主要逻辑
function c12247206.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 获取己方场上可用的怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if ft1>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft1=1 end
	-- 获取己方满足条件的可特殊召唤卡组（手牌·卡组·墓地）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12247206.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,e,tp)
	if ft1>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if g:GetCount()<=ft1 then
			c12247206.sp(g,tp,POS_FACEUP_ATTACK)
		else
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fg=g:Select(tp,ft1,ft1,nil)
			c12247206.sp(fg,tp,POS_FACEUP_ATTACK)
		end
	end
	-- 获取对方场上可用的怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-tp,59822133) then ft2=1 end
	-- 提示对方选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_FACEUP)
	-- 选择对方场上1只表侧表示的怪兽
	local sg=Duel.SelectMatchingCard(1-tp,Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,1,nil)
	if ft2>0 and sg:GetCount()>0 then
		-- 获取对方满足条件的可特殊召唤卡组（手牌·卡组·墓地）
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12247206.spfilter2),1-tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,sg:GetFirst(),e,1-tp)
		if g2:GetCount()>0 then
			if g2:GetCount()<=ft2 then
				c12247206.sp(g2,1-tp,POS_FACEUP)
			else
				-- 提示对方选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
				local fg=g2:Select(1-tp,ft2,ft2,nil)
				c12247206.sp(fg,1-tp,POS_FACEUP)
			end
		end
	end
	-- 完成所有特殊召唤步骤，结束效果处理
	Duel.SpecialSummonComplete()
end
