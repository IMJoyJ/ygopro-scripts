--燈影の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：和这张卡相同纵列的对方的卡从场上离开的场合或者被战斗破坏的场合才能发动。从手卡把1只「机界骑士」怪兽特殊召唤。
function c93020401.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,93020401+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c93020401.hspcon)
	e1:SetValue(c93020401.hspval)
	c:RegisterEffect(e1)
	-- ②：和这张卡相同纵列的对方的卡从场上离开的场合或者被战斗破坏的场合才能发动。从手卡把1只「机界骑士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93020401,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c93020401.spcon)
	e2:SetTarget(c93020401.sptg)
	e2:SetOperation(c93020401.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片所在的纵列是否存在其他卡片（即与该卡相同纵列的其他卡片数量大于0）
function c93020401.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 自身特殊召唤规则的条件函数：计算满足‘相同纵列有2张以上卡片存在’的纵列区域，并检查自己场上这些纵列是否有空位
function c93020401.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取双方场上所有‘所在纵列有2张或以上卡片存在’的卡片组
	local lg=Duel.GetMatchingGroup(c93020401.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些满足条件的卡片
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 检查在计算出的可用纵列区域中，自己场上是否存在可用于特殊召唤的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 自身特殊召唤规则的数值函数：计算并返回允许特殊召唤的怪兽区域（zone）
function c93020401.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取双方场上所有‘所在纵列有2张或以上卡片存在’的卡片组
	local lg=Duel.GetMatchingGroup(c93020401.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些满足条件的卡片
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 过滤函数：检查离场的卡片是否原本是对方控制，且原本处于与这张卡相同的纵列
function c93020401.spcfilter(c,tp,mc)
	if c:IsPreviousControler(tp) then return false end
	local zone=mc:GetColumnZone(LOCATION_ONFIELD)
	local seq=c:GetPreviousSequence()+16
	if c:IsPreviousLocation(LOCATION_SZONE) then seq=seq+8 end
	return zone and bit.extract(zone,seq)~=0
end
-- 效果发动条件：检查离场的卡片中是否存在满足条件的对方卡片
function c93020401.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c93020401.spcfilter,1,nil,tp,e:GetHandler())
end
-- 过滤函数：检查手牌中是否存在可以特殊召唤的「机界骑士」怪兽
function c93020401.filter(c,e,tp)
	return c:IsSetCard(0x10c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查自身怪兽区域是否有空位，且手牌中是否存在可特殊召唤的「机界骑士」怪兽，并设置特殊召唤的操作信息
function c93020401.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1只可以特殊召唤的「机界骑士」怪兽
		and Duel.IsExistingMatchingCard(c93020401.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：从手牌选择1只「机界骑士」怪兽特殊召唤到自己场上
function c93020401.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「机界骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c93020401.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
