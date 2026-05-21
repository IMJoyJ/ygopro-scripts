--ゲートウェイ・ドラゴン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：对方场上有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只4星以下的龙族·暗属性怪兽特殊召唤。
function c91482773.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91482773+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91482773.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从手卡把1只4星以下的龙族·暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91482773,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c91482773.sptg)
	e2:SetOperation(c91482773.spop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上表侧表示的连接怪兽
function c91482773.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 判断自身特殊召唤的条件是否满足（自己场上有空位且对方场上有连接怪兽存在）
function c91482773.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只表侧表示的连接怪兽
		and Duel.IsExistingMatchingCard(c91482773.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤手卡中满足4星以下、龙族、暗属性且能特殊召唤的怪兽
function c91482773.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测，检查自己场上是否有空位且手卡中是否存在满足条件的怪兽
function c91482773.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查手卡中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c91482773.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从手卡特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理，从手卡将1只满足条件的怪兽特殊召唤
function c91482773.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上已没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c91482773.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
