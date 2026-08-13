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
	-- 将效果适用对象限定为场上拥有「弹丸」字段的怪兽，使这些怪兽受到守备力提升300的效果。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x102))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：可以从以下效果选择1个发动。●从手卡把最多2只「弹丸」怪兽守备表示特殊召唤（同名卡最多1张）。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36668118,0))  --"从手卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,36668118)
	e4:SetTarget(c36668118.sptg1)
	e4:SetOperation(c36668118.spop1)
	c:RegisterEffect(e4)
	-- 这个卡名的②的效果1回合只能使用1次。②：可以从以下效果选择1个发动。●对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「弹丸」怪兽从自己墓地守备表示特殊召唤（同名卡最多1张）。
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
-- 定义本卡特殊召唤效果的可用怪兽条件：必须是「弹丸」字段怪兽，并且可以被当前玩家以表侧守备表示特殊召唤（需满足召唤条件与苏生限制）。
function c36668118.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 手卡特殊召唤效果发动前的合法性检查：自己主要怪兽区有空位，且自己手牌存在至少1只满足特殊召唤条件的「弹丸」怪兽。
function c36668118.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在至少1只满足特殊召唤条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c36668118.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示己方选择了发动手卡特殊召唤效果（显示该效果的描述信息）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的处理信息：效果分类为特殊召唤，从手卡特殊召唤，预计处理数量为1张（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 手卡特殊召唤效果的处理：计算可用空格与手牌中的可特殊召唤「弹丸」怪兽；若无空位或无怪兽则终止；若「青眼精灵龙」效果适用，则将可特殊召唤数量上限限制为1；然后由玩家选择1到min(空格数,2)张卡名互不相同的「弹丸」怪兽，以表侧守备表示特殊召唤。
function c36668118.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己手牌中所有满足特殊召唤条件的「弹丸」怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c36668118.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if ft<1 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，要求玩家选择要特殊召唤的「弹丸」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选择1到min(空格数,2)张且卡名互不相同的「弹丸」怪兽，作为实际特殊召唤的对象。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,2))
	-- 将选中的「弹丸」怪兽以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 墓地特殊召唤效果可以发动的条件：对方场上的怪兽数量多于自己场上的怪兽数量。
function c36668118.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方主要怪兽区的怪兽数量：对方多于己方时返回true。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 墓地特殊召唤效果发动前的合法性检查：自己主要怪兽区有空位，且自己墓地存在至少1只满足特殊召唤条件的「弹丸」怪兽。
function c36668118.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1只满足特殊召唤条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c36668118.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示己方选择了发动墓地特殊召唤效果（显示该效果的描述信息）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的处理信息：效果分类为特殊召唤，从墓地特殊召唤，预计处理数量为1张（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地特殊召唤效果的处理：计算可用空格数与对方比我方多出的怪兽数；若没有空位或差值为0或墓地无符合条件的怪兽则终止；若「青眼精灵龙」效果适用，则上限限制为1；由玩家选择1到min(空格数,差值)张卡名互不相同的「弹丸」怪兽，以表侧守备表示特殊召唤。
function c36668118.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算对方场上怪兽数量与我方场上怪兽数量的差值，即最多可从墓地特殊召唤的数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 获取自己墓地中所有满足特殊召唤条件的「弹丸」怪兽组成的集合。
	local g=Duel.GetMatchingGroup(c36668118.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<1 or ct<1 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，要求玩家选择要特殊召唤的「弹丸」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选择1到min(空格数,差值)张且卡名互不相同的「弹丸」怪兽，作为实际特殊召唤的对象。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,ct))
	-- 将选中的「弹丸」怪兽以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
