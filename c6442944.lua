--カイザー・シースネーク
-- 效果：
-- 「帝王海蛇」的①的方法的特殊召唤1回合只能有1次。
-- ①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡用这张卡的①的方法特殊召唤成功时才能发动。从自己的手卡·墓地选1只海龙族·8星怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0。
-- ③：特殊召唤的这张卡的等级变成4星，原本攻击力变成0。
function c6442944.initial_effect(c)
	-- 「帝王海蛇」的①的方法的特殊召唤1回合只能有1次。①：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetValue(SUMMON_VALUE_SELF)
	e1:SetCountLimit(1,6442944+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c6442944.hspcon)
	c:RegisterEffect(e1)
	-- ②：这张卡用这张卡的①的方法特殊召唤成功时才能发动。从自己的手卡·墓地选1只海龙族·8星怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6442944,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c6442944.spcon)
	e2:SetTarget(c6442944.sptg)
	e2:SetOperation(c6442944.spop)
	c:RegisterEffect(e2)
	-- ③：特殊召唤的这张卡的等级变成4星，原本攻击力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetOperation(c6442944.lvop)
	c:RegisterEffect(e3)
end
-- 自身特殊召唤效果的判定条件
function c6442944.hspcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否存在怪兽（数量为0）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在怪兽（数量大于0）
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检查这张卡是否是用自身①的方法特殊召唤成功
function c6442944.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：手卡·墓地的8星·海龙族怪兽
function c6442944.spfilter(c,e,tp)
	return c:IsRace(RACE_SEASERPENT) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查
function c6442944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c6442944.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息为特殊召唤手卡·墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：特殊召唤手卡·墓地的1只8星·海龙族怪兽，并将其攻击力·守备力变成0
function c6442944.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6442944.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则将其特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果③的效果处理：特殊召唤的这张卡等级变成4星，原本攻击力变成0
function c6442944.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- 原本攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(0)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
