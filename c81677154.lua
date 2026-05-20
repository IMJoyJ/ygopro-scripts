--メメント・シーホース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有「莫忘」怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，等级合计最多到破坏的怪兽的原本等级以下为止，从卡组把「莫忘」怪兽送去墓地（同名卡最多1张）。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召）和②效果（破坏场上「莫忘」怪兽并从卡组送墓「莫忘」怪兽）。
function s.initial_effect(c)
	-- ①：自己场上没有「莫忘」怪兽以外的表侧表示怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上1只「莫忘」怪兽破坏，等级合计最多到破坏的怪兽的原本等级以下为止，从卡组把「莫忘」怪兽送去墓地（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示存在的非「莫忘」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1a1)
end
-- ①效果的发动条件：自己场上不存在非「莫忘」怪兽的表侧表示怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在非「莫忘」怪兽的表侧表示怪兽。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若自身仍在手卡，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关联，则以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤条件：自己场上表侧表示的「莫忘」怪兽，且卡组中存在等级在其原本等级以下、可送去墓地的「莫忘」怪兽。
function s.dfilter(c,tp)
	-- 检查该卡是否为表侧表示的「莫忘」怪兽，且卡组中是否存在等级在其原本等级以下、可送去墓地的「莫忘」怪兽。
	return c:IsFaceup() and c:IsSetCard(0x1a1) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalLevel())
end
-- 过滤条件：卡组中等级在指定数值以下、可以送去墓地的「莫忘」怪兽。
function s.filter(c,lv)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lv) and c:IsAbleToGrave()
end
-- ②效果的发动准备与合法性检测（检查是否有可破坏的「莫忘」怪兽，并设置破坏和送墓的操作信息）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足破坏条件的「莫忘」怪兽。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return #g>0 end
	-- 设置破坏的操作信息，表示将破坏自己场上1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_MZONE)
	-- 设置送去墓地的操作信息，表示将从卡组把怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 辅助检查函数：用于限制选取的卡片组中不能有同名卡，且等级合计不超过被破坏怪兽的原本等级。
function s.gcheck(lv)
	return	function(g)
				-- 检查卡片组内无同名卡，且等级合计不超过被破坏怪兽的原本等级。
				return aux.dncheck(g) and g:GetSum(Card.GetLevel)<=lv
			end
end
-- ②效果的处理：选择并破坏自己场上1只「莫忘」怪兽，然后从卡组选择等级合计在被破坏怪兽原本等级以下的「莫忘」怪兽（同名卡最多1张）送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1只满足条件的「莫忘」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	-- 破坏选中的怪兽，若未成功破坏则结束效果处理。
	if not tc or Duel.Destroy(tc,REASON_EFFECT)<1 then return end
	local lv=tc:GetOriginalLevel()
	-- 获取卡组中所有满足送墓条件的「莫忘」怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,lv)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 设置子卡片组选择的附加检查条件（限制同名卡及等级合计）。
	aux.GCheckAdditional=s.gcheck(lv)
	-- 让玩家从卡组选择满足附加检查条件的「莫忘」怪兽组合。
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,lv)
	-- 重置附加检查条件，避免影响后续的其他选择。
	aux.GCheckAdditional=nil
	-- 若成功选择，则将选中的怪兽送去墓地。
	if sg then Duel.SendtoGrave(sg,REASON_EFFECT) end
end
