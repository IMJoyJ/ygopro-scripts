--ヴァレット・キャリバー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为暗属性连接怪兽所连接区的自己场上特殊召唤。
-- ②：把这张卡解放才能发动。从手卡把「弹丸口径龙」以外的1只龙族·机械族的暗属性怪兽特殊召唤。
function c67127799.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为暗属性连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,67127799+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c67127799.spcon)
	e1:SetValue(c67127799.spval)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：把这张卡解放才能发动。从手卡把「弹丸口径龙」以外的1只龙族·机械族的暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67127799,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,67127800)
	e2:SetCost(c67127799.spcost2)
	e2:SetTarget(c67127799.sptg2)
	e2:SetOperation(c67127799.spop2)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的暗属性连接怪兽
function c67127799.linkedfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_LINK)
end
-- 获取玩家场上所有暗属性连接怪兽所连接的、属于自己主要怪兽区域的格子掩码
function c67127799.checkzone(tp)
	local zone=0
	-- 获取场上所有的暗属性连接怪兽
	local g=Duel.GetMatchingGroup(c67127799.linkedfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历这些暗属性连接怪兽
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
-- 特殊召唤规则的条件：检查自己场上是否存在可用的、处于暗属性连接怪兽连接区内的怪兽区域
function c67127799.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=c67127799.checkzone(tp)
	-- 检查在指定的连接区格子内是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 确定特殊召唤规则所指向的可用怪兽区域（zone）
function c67127799.spval(e,c)
	local tp=c:GetControler()
	local zone=c67127799.checkzone(tp)
	return 0,zone
end
-- 效果②的发动代价：解放自身
function c67127799.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(c,REASON_COST)
end
-- 过滤手卡中「弹丸口径龙」以外的、可以特殊召唤的龙族或机械族的暗属性怪兽
function c67127799.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON+RACE_MACHINE)
		and not c:IsCode(67127799) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查怪兽区域空位及手卡中是否存在可特殊召唤的合法怪兽，并设置特殊召唤的操作信息）
function c67127799.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身解放后，自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c67127799.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理：从手卡选择1只满足条件的怪兽特殊召唤
function c67127799.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c67127799.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
