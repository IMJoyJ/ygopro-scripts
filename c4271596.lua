--灰滅せし都の王
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从手卡把「灰灭都之王」以外的1只「灰灭」怪兽特殊召唤。对方场上有攻击力2800以上的怪兽存在的场合，也能作为代替从卡组选。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①特殊召唤条件；②起动效果
function s.initial_effect(c)
	-- 记录该卡与「灰灭之都 奥布西地暮」的关联
	aux.AddCodeList(c,3055018)
	-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从手卡把「灰灭都之王」以外的1只「灰灭」怪兽特殊召唤。对方场上有攻击力2800以上的怪兽存在的场合，也能作为代替从卡组选。
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
-- 过滤函数，用于判断场地区域是否存在「灰灭之都 奥布西地暮」
function s.sprfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- 判断特殊召唤条件是否满足：手卡特殊召唤时，场上必须有「灰灭之都 奥布西地暮」且有空场
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有空场且存在「灰灭之都 奥布西地暮」
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤函数，用于筛选「灰灭」怪兽且不是本卡
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ad) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选攻击力2800以上的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2800)
end
-- 设置效果发动时的处理目标：判断是否可以发动效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有空场
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在符合条件的「灰灭」怪兽，且对方场上有攻击力2800以上的怪兽
		and (Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)) end
	-- 设置操作信息：确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果发动时的特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否还有空场
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取手卡中符合条件的「灰灭」怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 判断对方场上有攻击力2800以上的怪兽
	if Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 将卡组中符合条件的「灰灭」怪兽加入到可选列表
		g:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp))
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sc=g:Select(tp,1,1,nil)
	if sc then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
