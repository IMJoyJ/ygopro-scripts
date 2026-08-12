--御巫の火叢舞
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把1只「御巫」怪兽特殊召唤，把这张卡装备。那之后，可以从对方墓地把1只怪兽效果无效在对方场上特殊召唤。
-- ②：装备怪兽不会被效果破坏。
function c80044027.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「御巫」怪兽特殊召唤，把这张卡装备。那之后，可以从对方墓地把1只怪兽效果无效在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80044027,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,80044027+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c80044027.target)
	e1:SetOperation(c80044027.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·墓地的「御巫」怪兽
function c80044027.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查
function c80044027.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只可以特殊召唤的「御巫」怪兽
		and Duel.IsExistingMatchingCard(c80044027.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	-- 设置装备卡的操作信息（将这张卡装备）
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给这张卡
function c80044027.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果①的处理过程
function c80044027.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的「御巫」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c80044027.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤并装备这张卡
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 把这张卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c80044027.eqlimit)
		c:RegisterEffect(e1)
		-- 获取对方墓地中可以特殊召唤的怪兽组（受王家长眠之谷影响）
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,0,LOCATION_GRAVE,nil,e,0,tp,false,false,POS_FACEUP,1-tp)
		-- 若对方场上有空位且对方墓地有可特召怪兽，询问玩家是否进行特殊召唤
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(80044027,1)) then  --"是否选对方怪兽在对方场上特殊召唤？"
			-- 中断效果，使后续的特殊召唤处理与前面的特殊召唤·装备不视为同时进行（那之后）
			Duel.BreakEffect()
			-- 提示玩家选择对方墓地中要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			-- 将选中的对方怪兽在对方场上特殊召唤（分步处理以适用无效效果）
			if Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP) then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			-- 完成特殊召唤的后续处理
			Duel.SpecialSummonComplete()
		end
	end
end
