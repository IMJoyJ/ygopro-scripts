--仲間の絆
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的场合才能发动。把有「光之黄金柜」的卡名记述的最多2只4星以下的怪兽从手卡·卡组特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化入口：将「光之黄金柜」的卡名登记到本卡，然后创建并注册该卡的魔法发动效果（1回合1次，满足条件时从手卡·卡组特殊召唤，发动后附加自肃）。
function s.initial_effect(c)
	-- 将「光之黄金柜」(79791878)记录为这张卡效果文本中记载的卡名，供 aux.IsCodeListed 检索判断。
	aux.AddCodeList(c,79791878)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的场合才能发动。把有「光之黄金柜」的卡名记述的最多2只4星以下的怪兽从手卡·卡组特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义条件过滤函数1：用于检查场上是否存在表侧表示的「光之黄金柜」(79791878)。
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 定义条件过滤函数2：用于检查场上是否存在表侧表示且卡名记述了「光之黄金柜」的怪兽。
function s.cfilter2(c)
	-- 判断怪兽c处于表侧表示，并且其效果文本中记载有「光之黄金柜」的卡名。
	return c:IsFaceup() and aux.IsCodeListed(c,79791878)
end
-- 定义本卡的发动条件：自己场上存在表侧表示的「光之黄金柜」，并且自己怪兽区域存在表侧表示且卡名记述有「光之黄金柜」的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否至少存在1张表侧表示的「光之黄金柜」。
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
			-- 并且检查自己怪兽区域是否至少存在1只表侧表示且卡名记述有「光之黄金柜」的怪兽。
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义特殊召唤候选的过滤函数：怪兽的卡名必须记述有「光之黄金柜」、等级4以下，并且能通过这个效果特殊召唤。
function s.spfilter(c,e,tp)
	-- 判断候选怪兽是否满足“卡名记述有「光之黄金柜」、等级4以下且可以被特殊召唤”的条件。
	return aux.IsCodeListed(c,79791878) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end
-- 定义发动时的目标确认：在发动时检查自己场上是否有可用怪兽区域，并且手卡·卡组中存在满足条件的特殊召唤候选。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查时，要求自己场上存在可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡·卡组中存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，声明这个效果将怪兽从手卡·卡组特殊召唤，用于触发相关卡片的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡·卡组选择至多2只满足条件且卡名各不相同的4星以下怪兽表侧表示特殊召唤；若「青眼精灵龙」的效果适用中则只能特殊召唤1只；特殊召唤后给自己附加直到回合结束不能从额外卡组特殊召唤的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上当前可用的主要怪兽区域数量，作为本次特殊召唤数量上限的参考。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手卡·卡组中所有满足特殊召唤条件的怪兽组成的集合。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 and ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ct=math.min(ft,2)
		-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从候选集合中选择1至ct张卡，并通过 aux.dncheck 确保所选卡片卡名互不相同。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将自肃效果注册给玩家tp，使其在该回合内受到不能从额外卡组特殊召唤的限制。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义自肃限制的判定条件：若试图特殊召唤的怪兽位于额外卡组，则禁止特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
