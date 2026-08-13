--選手入場アナウンス
-- 效果：
-- 这个卡名在规则上也当作「燃烧拳」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「燃烧拳击手」怪兽特殊召唤。那之后，可以把最多有自己场上的超量怪兽数量的场上的魔法·陷阱卡破坏。
local s,id,o=GetID()
-- 定义并注册该卡的发动效果：生成一个效果e1，设置为魔法卡发动，自由时点可发动，一回合一次（誓约次数），效果为特殊召唤手牌的燃烧拳击手怪兽并可能破坏魔法·陷阱卡，最后注册到该卡上。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把1只「燃烧拳击手」怪兽特殊召唤。那之后，可以把最多有自己场上的超量怪兽数量的场上的魔法·陷阱卡破坏。
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
-- 过滤器：判断手牌中的怪兽是否为「燃烧拳击手」字段，并且能够被当前效果特殊召唤。
function s.filter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检测：己方主要怪兽区有空位，并且手牌中存在至少1只满足s.filter（「燃烧拳击手」且可特殊召唤）的怪兽，才能发动此卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方主要怪兽区是否有空位，用于后续特殊召唤；没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌中是否存在至少1只满足s.filter（「燃烧拳击手」且可被当前效果特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果处理将进行特殊召唤，对象来自手牌，数量为1，由tp玩家操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤器：统计己方场上表侧表示的超量怪兽数量，用于决定之后最多可以破坏的魔法·陷阱卡数量。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果处理：先从手牌特殊召唤1只「燃烧拳击手」怪兽；若特殊召唤成功，再根据己方场上超量怪兽的数量，最多选择等量的场上魔法·陷阱卡破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次检查己方主要怪兽区是否有空位，若无空位则效果不处理（无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示文字，要求玩家从手牌中选择要特殊召唤的怪兽（HINTMSG_SPSUMMON为特殊召唤选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1只满足s.filter的「燃烧拳击手」怪兽，作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 执行特殊召唤，以表侧表示特殊召唤到己方场上；若特殊召唤成功数量为0，则直接结束后续处理。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取场上双方所有魔法·陷阱卡，作为可能被破坏的候选集合。
	local tg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 统计己方场上表侧表示的超量怪兽数量，该数量决定了最多可破坏的魔法·陷阱卡数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 只有己方存在超量怪兽、场上有魔法·陷阱卡可选，且玩家选择“是”时，才执行破坏；否则不破坏。
	if ct>0 and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否破坏魔法·陷阱卡？"
		-- 弹出提示文字，要求玩家从候选的魔法·陷阱卡中选择要破坏的卡（HINTMSG_DESTROY为破坏选择提示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=tg:Select(tp,1,ct,nil)
		-- 手动显示所选破坏对象的选中动画，并将它们记录为当前效果处理的对象。
		Duel.HintSelection(dg)
		-- 中断当前效果处理，使特殊召唤和随后的破坏被视为不同时处理，避免卡掉时点。
		Duel.BreakEffect()
		-- 以效果破坏选中的魔法·陷阱卡，破坏原因为效果（REASON_EFFECT），送入墓地。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
