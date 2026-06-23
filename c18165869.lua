--メメント・ダークソード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，从手卡丢弃1张「莫忘」卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把1只3星以下的「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果，注册①②效果，①为通常召唤或特殊召唤时发动，②为场上的起动效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，从手卡丢弃1张「莫忘」卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把1只3星以下的「莫忘」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断手卡中是否存在可丢弃的「莫忘」卡
function s.cfilter(c)
	return c:IsSetCard(0x1a1) and c:IsDiscardable()
end
-- 效果发动时的费用处理，丢弃1张手卡中的「莫忘」卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1张「莫忘」卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡中的「莫忘」卡的操作
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，判断是否为魔法或陷阱卡
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的发动目标选择，选择对方场上的1张魔法或陷阱卡作为破坏对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 检查是否满足选择对方场上1张魔法或陷阱卡的条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的发动处理，破坏选择的魔法或陷阱卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，判断场上是否存在可破坏的「莫忘」怪兽
function s.dfilter(c,tp)
	-- 判断场上怪兽是否为「莫忘」卡且有可用怪兽区
	return c:IsFaceup() and c:IsSetCard(0x1a1) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，判断卡组中是否存在3星以下的「莫忘」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(3) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标选择，选择场上1只「莫忘」怪兽破坏并从卡组特殊召唤1只3星以下的「莫忘」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可破坏的「莫忘」怪兽
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 检查是否满足破坏1只「莫忘」怪兽并从卡组特殊召唤1只3星以下的「莫忘」怪兽的条件
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理，破坏场上1只「莫忘」怪兽并从卡组特殊召唤1只3星以下的「莫忘」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只「莫忘」怪兽作为破坏对象
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 判断破坏是否成功且场上存在可用怪兽区
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只3星以下的「莫忘」怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
