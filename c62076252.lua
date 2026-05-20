--スレイブベアー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：从卡组·额外卡组特殊召唤的「剑斗兽」怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放，从自己的手卡·场上（表侧表示）让1只「剑斗兽」怪兽回到卡组·额外卡组才能发动。把最多2只「剑斗兽」怪兽当作「剑斗兽」怪兽的效果的特殊召唤从卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤规则，②解放自身并让1只「剑斗兽」回到卡组来从卡组特殊召唤最多2只「剑斗兽」的起动效果
function s.initial_effect(c)
	-- ①：从卡组·额外卡组特殊召唤的「剑斗兽」怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，从自己的手卡·场上（表侧表示）让1只「剑斗兽」怪兽回到卡组·额外卡组才能发动。把最多2只「剑斗兽」怪兽当作「剑斗兽」怪兽的效果的特殊召唤从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示存在、且是从卡组或额外卡组特殊召唤的「剑斗兽」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x1019) and c:IsFaceup() and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ①号效果（手卡特殊召唤）的发动条件：自身怪兽区域有空位，且场上存在满足条件的「剑斗兽」怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在从卡组·额外卡组特殊召唤的表侧表示「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡或场上表侧表示的、可以作为代价回到卡组或额外卡组的「剑斗兽」怪兽，且其离开后场上必须有空余怪兽区域
function s.tdfilter(c,tp,ec)
	local g=Group.FromCards(c,ec)
	return c:IsFaceupEx() and c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeckOrExtraAsCost()
		-- 检查在解放自身以及将选中的「剑斗兽」送回卡组后，自己场上是否还有可用的怪兽区域
		and Duel.GetMZoneCount(tp,g)>0
end
-- ②号效果的发动代价：解放自身，并让手卡·场上1只「剑斗兽」怪兽回到卡组·额外卡组
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查手卡或场上是否存在满足回到卡组条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler(),tp,e:GetHandler()) end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 玩家选择手卡或场上表侧表示的1只「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp,e:GetHandler())
	local gc=g:GetFirst()
	if gc:IsLocation(LOCATION_HAND) then
		-- 若选中的是手卡中的怪兽，则向对方展示以作确认
		Duel.ConfirmCards(1-tp,gc)
	end
	if gc:IsLocation(LOCATION_MZONE) then
		-- 若选中的是场上的怪兽，则在场上显式提示该卡被选中
		Duel.HintSelection(g)
	end
	-- 将选中的「剑斗兽」怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「剑斗兽」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备：检查卡组中是否存在可特殊召唤的「剑斗兽」怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认卡组中是否存在至少1只可以特殊召唤的「剑斗兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的效果处理：计算可用怪兽区域，从卡组选择最多2只「剑斗兽」怪兽特殊召唤，并将其视为用「剑斗兽」怪兽的效果特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1到ft张（最多2张）满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以「剑斗兽」怪兽效果特殊召唤的数值（SUMMON_VALUE_GLADIATOR）表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,SUMMON_VALUE_GLADIATOR,tp,tp,false,false,POS_FACEUP)
		-- 遍历特殊召唤成功的所有怪兽，为其注册对应的标记效果（用于后续判定）
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		end
	end
end
