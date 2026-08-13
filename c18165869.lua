--メメント・ダークソード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，从手卡丢弃1张「莫忘」卡，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，从卡组把1只3星以下的「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化函数，为卡片注册两个效果：①为召唤·特殊召唤成功时发动的诱发选发效果，丢弃手卡「莫忘」卡并取对象破坏对方场上1张魔法·陷阱卡；②为起动效果，主要阶段破坏己方场上1只「莫忘」怪兽，从卡组特殊召唤1只3星以下的「莫忘」怪兽。同时①效果被复制为特殊召唤成功时也能发动的效果实例，两个效果均设有一回合一次的次数限制。
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
-- 该过滤函数用于筛选手卡中属于「莫忘」字段且可以被丢弃（作为代价）的卡片。
function s.cfilter(c)
	return c:IsSetCard(0x1a1) and c:IsDiscardable()
end
-- 该函数作为①效果的发动代价，先检测手卡中是否存在可丢弃的「莫忘」卡，若存在则选择并丢弃1张作为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）检查手卡中是否存在至少1张满足s.cfilter条件的「莫忘」卡，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 选择并丢弃1张满足条件的「莫忘」手卡，丢弃原因同时标记为代价和丢弃，作为效果发动的代价。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 该过滤函数用于筛选魔法·陷阱卡，作为对方场上可选为破坏对象的卡。
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 该函数作为①效果的发动目标指定阶段：确认对方场上有可选的魔法·陷阱卡时，让玩家选择1张作为对象，并设置破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 在目标检测阶段（chk==0）检查对方场上是否存在至少1张可以被取对象的魔法·陷阱卡，以判断能否发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示消息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张魔法·陷阱卡，并将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置该连锁的破坏操作信息，记录预定破坏的对象及其数量，供其他卡片进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 该函数作为①效果的处理：取得效果对象，若对象仍与效果关联，则将其破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 该过滤函数用于筛选己方场上表侧表示且属于「莫忘」字段的怪兽，并确认该怪兽被破坏后己方场上仍有可用怪兽区空间。
function s.dfilter(c,tp)
	-- 筛选条件：表侧表示、属于「莫忘」字段，且该卡离开后己方场上仍有可用怪兽区。
	return c:IsFaceup() and c:IsSetCard(0x1a1) and Duel.GetMZoneCount(tp,c)>0
end
-- 该过滤函数用于筛选卡组中3星以下、属于「莫忘」字段且能被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(3) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该函数作为②效果的目标指定阶段：确认己方场上有可破坏的「莫忘」怪兽且卡组中有可特殊召唤的「莫忘」怪兽，然后登记破坏和特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得己方场上所有满足s.dfilter条件的「莫忘」怪兽，作为可被破坏的候选组。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 在目标检测阶段（chk==0）确认己方场上有可破坏的莫忘怪兽，且卡组中至少有1只可特殊召唤的3星以下莫忘怪兽。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置破坏操作信息，预定破坏己方场上1只莫忘怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作信息，预定从卡组特殊召唤1只莫忘怪兽，具体怪兽在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 该函数作为②效果的处理：先选择并破坏己方场上1只莫忘怪兽，若破坏成功且己方怪兽区仍有空位，则从卡组选择1只3星以下的莫忘怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示消息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从己方场上选择1只满足s.dfilter条件的「莫忘」怪兽作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 实际破坏选中的莫忘怪兽，若破坏成功且己方怪兽区仍有空位，则继续执行特殊召唤处理。
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示消息，提示内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足s.spfilter条件的「莫忘」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			-- 将选择的「莫忘」怪兽以表侧攻击表示特殊召唤到己方场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
