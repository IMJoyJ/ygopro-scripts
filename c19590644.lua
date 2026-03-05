--セットアッパー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己怪兽被战斗破坏时才能发动。把持有那只怪兽的攻击力以下的攻击力的1只怪兽从手卡·卡组里侧守备表示特殊召唤。
function c19590644.initial_effect(c)
	-- 效果原文内容：①：自己怪兽被战斗破坏时才能发动。把持有那只怪兽的攻击力以下的攻击力的1只怪兽从手卡·卡组里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,19590644+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19590644.condition)
	e1:SetTarget(c19590644.target)
	e1:SetOperation(c19590644.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出上一个控制者为自己方的怪兽
function c19590644.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 效果作用：判断是否满足发动条件，获取被战斗破坏怪兽的攻击力并设置为效果标签
function c19590644.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:Filter(c19590644.cfilter,nil,tp):GetFirst()
	if not tc then return false end
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	return true
end
-- 效果作用：筛选攻击力不超过指定值且能里侧守备表示特殊召唤的怪兽
function c19590644.spfilter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果作用：判断是否满足发动条件，检查手卡和卡组中是否存在满足条件的怪兽
function c19590644.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡和卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c19590644.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 效果作用：设置连锁处理信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果作用：执行效果处理，选择并特殊召唤符合条件的怪兽
function c19590644.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c19590644.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	-- 效果作用：将选中的怪兽特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 效果作用：向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
