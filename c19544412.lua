--選手入場アナウンス
-- 效果：
-- 这个卡名在规则上也当作「燃烧拳」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「燃烧拳击手」怪兽特殊召唤。那之后，可以把最多有自己场上的超量怪兽数量的场上的魔法·陷阱卡破坏。
local s,id,o=GetID()
-- 创建效果，设置效果描述、分类、类型、时点、发动限制和处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手牌中是否含有「燃烧拳击手」怪兽且可以特殊召唤
function s.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时点，检查是否满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的「燃烧拳击手」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤函数，用于判断场上是否有超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果发动处理函数，执行特殊召唤和可能的破坏效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「燃烧拳击手」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取场上的魔法·陷阱卡
	local tg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 统计自己场上的超量怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 判断是否可以发动破坏效果
	if ct>0 and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏魔法·陷阱卡？"
		-- 提示玩家选择要破坏的魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=tg:Select(tp,1,ct,nil)
		-- 显示被选中的卡作为破坏对象
		Duel.HintSelection(dg)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 将选中的魔法·陷阱卡破坏
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
