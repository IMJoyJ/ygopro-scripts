--リボルブート・セクター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上的「弹丸」怪兽的攻击力·守备力上升300。
-- ②：可以从以下效果选择1个发动。
-- ●从手卡把最多2只「弹丸」怪兽守备表示特殊召唤（同名卡最多1张）。
-- ●对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「弹丸」怪兽从自己墓地守备表示特殊召唤（同名卡最多1张）。
function c36668118.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「弹丸」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选满足「弹丸」卡组的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x102))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	c:RegisterEffect(e3)
	-- ②：可以从以下效果选择1个发动。●从手卡把最多2只「弹丸」怪兽守备表示特殊召唤（同名卡最多1张）。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36668118,0))  --"从手卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,36668118)
	e4:SetTarget(c36668118.sptg1)
	e4:SetOperation(c36668118.spop1)
	c:RegisterEffect(e4)
	-- ②：可以从以下效果选择1个发动。●对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「弹丸」怪兽从自己墓地守备表示特殊召唤（同名卡最多1张）。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(36668118,1))  --"从墓地特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,36668118)
	e5:SetCondition(c36668118.spcon)
	e5:SetTarget(c36668118.sptg2)
	e5:SetOperation(c36668118.spop2)
	c:RegisterEffect(e5)
end
-- 用于筛选满足条件的「弹丸」怪兽，可特殊召唤
function c36668118.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断手卡是否存在满足条件的「弹丸」怪兽并检查是否有足够的召唤位置
function c36668118.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c36668118.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行从手卡特殊召唤的操作
function c36668118.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的「弹丸」怪兽组
	local g=Duel.GetMatchingGroup(c36668118.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if ft<1 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的怪兽组中选择最多2只不同卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,2))
	-- 将选中的怪兽以守备表示特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断对方场上的怪兽数量是否比自己场上的多
function c36668118.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 判断墓地是否存在满足条件的「弹丸」怪兽并检查是否有足够的召唤位置
function c36668118.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c36668118.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行从墓地特殊召唤的操作
function c36668118.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算双方场上的怪兽数量差
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 获取满足条件的「弹丸」怪兽组
	local g=Duel.GetMatchingGroup(c36668118.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<1 or ct<1 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的怪兽组中选择最多与数量差相等的不同卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选中的怪兽以守备表示特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
