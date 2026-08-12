--仲間の絆
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的场合才能发动。把有「光之黄金柜」的卡名记述的最多2只4星以下的怪兽从手卡·卡组特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，注册发动条件、目标和处理函数
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「光之黄金柜」（79791878）的卡名
	aux.AddCodeList(c,79791878)
	-- ①：自己场上有着「光之黄金柜」以及有那个卡名记述的怪兽存在的场合才能发动。
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
-- 检查自己场上是否存在「光之黄金柜」（79791878）的表侧表示怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 检查自己场上是否存在有「光之黄金柜」（79791878）卡名记述的表侧表示怪兽
function s.cfilter2(c)
	-- 有「光之黄金柜」的卡名记述
	return c:IsFaceup() and aux.IsCodeListed(c,79791878)
end
-- 判断发动条件是否满足：自己场上存在「光之黄金柜」且存在有其卡名记述的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「光之黄金柜」（79791878）的表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
			-- 检查自己场上是否存在有「光之黄金柜」（79791878）卡名记述的表侧表示怪兽
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选可以特殊召唤的怪兽条件：有「光之黄金柜」卡名记述、等级4以下、可特殊召唤
function s.spfilter(c,e,tp)
	-- 有「光之黄金柜」卡名记述、等级4以下、可特殊召唤
	return aux.IsCodeListed(c,79791878) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end
-- 设置发动时的处理条件：确认自己场上是否有足够的怪兽区域及手卡/卡组中是否存在满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置发动时的操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 发动处理函数，执行特殊召唤操作并设置后续限制效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手卡和卡组中满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 and ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ct=math.min(ft,2)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽组中选择最多2只且卡名不同的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将选中的怪兽特殊召唤到场上
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
		-- 注册不能从额外卡组特殊召唤的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的目标为额外卡组的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
