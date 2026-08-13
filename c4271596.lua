--灰滅せし都の王
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从手卡把「灰灭都之王」以外的1只「灰灭」怪兽特殊召唤。对方场上有攻击力2800以上的怪兽存在的场合，也能作为代替从卡组选。
local s,id,o=GetID()
-- 在 initial_effect 中为这张卡注册两个效果：e1 是①的规则特殊召唤效果（无种类、不可复制、手牌起效、1回合1次誓约限制），e2 是②的起动特殊召唤效果（1回合1次，从手牌或卡组特殊召唤「灰灭」怪兽）。
function s.initial_effect(c)
	-- 记载这张卡文本中提到的「灰灭之都 奥布西地暮」的卡号3055018，用于关联查询。
	aux.AddCodeList(c,3055018)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从手卡把「灰灭都之王」以外的1只「灰灭」怪兽特殊召唤。对方场上有攻击力2800以上的怪兽存在的场合，也能作为代替从卡组选。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡片为表侧表示且卡号为3055018，即「灰灭之都 奥布西地暮」。
function s.sprfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- ①特殊召唤的规则条件：当c为nil时视为可发动；否则检查控制者tp的主怪兽区是否有空位，且tp的场地区域存在表侧表示的「灰灭之都 奥布西地暮」。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断tp的主怪兽区空格数>0，且其场地区存在至少1张满足s.sprfilter的卡（表侧表示的灰灭之都 奥布西地暮）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 筛选可作为特殊召唤对象的「灰灭」（0x1ad）怪兽：卡名不是这张卡自身（id），且能够被效果e由tp特殊召唤（检查召唤条件和苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ad) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断怪兽是否为表侧表示且攻击力2800以上，用于检测对方场上是否存在符合条件的怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2800)
end
-- ②效果的发动条件：自己主要阶段且主怪兽区有空位，并且手牌存在可特殊召唤的「灰灭」怪兽，或（卡组存在可特殊召唤的「灰灭」怪兽且对方场上有攻击力2800以上的表侧怪兽）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时先检查自己主怪兽区是否有可用空格，无空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 进一步检查特殊召唤对象来源：手牌中有符合条件的「灰灭」怪兽，或者对方场上有攻击力2800以上怪兽时卡组中也有符合条件的「灰灭」怪兽。
		and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)) end
	-- 设置本次效果处理的信息为特殊召唤，预定处理1张卡，来源范围包括手牌和卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：先确认主怪兽区有空格；取出可特殊召唤的手牌「灰灭」怪兽作为候选；若对方场上有攻击力2800以上的怪兽，则把卡组中符合条件的「灰灭」怪兽也加入候选；提示玩家选择其中1只，并以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若主怪兽区没有可用空格，则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得自己手牌中所有满足s.spfilter的「灰灭」怪兽（不含自身且可特殊召唤），作为初始候选组。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 检查对方场上是否存在表侧表示且攻击力2800以上的怪兽，决定是否额外允许从卡组选择。
	if Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 当对方场上有攻击力2800以上的怪兽时，将卡组中所有可特殊召唤的「灰灭」怪兽并入候选组，使玩家也能从卡组选择。
		g:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp))
	end
	-- 弹出“请选择要特殊召唤的卡”的提示消息，供玩家选择候选怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sc=g:Select(tp,1,1,nil)
	if sc then
		-- 将选中的怪兽以表侧表示特殊召唤到玩家tp自己的主要怪兽区，并正常检查召唤条件和苏生限制。
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
