--Angelechy Problem
-- 效果：
-- 1回合1次：可以丢弃1张魔法·陷阱卡；从额外卡组把1只2星「具象天使」怪兽特殊召唤，从额外卡组把1只「具象天使」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置。
-- 自己场上表侧表示的「具象天使」怪兽卡被战斗·效果破坏的场合：可以让自己魔法与陷阱区域的1张原本持有者是自己的「具象天使」怪兽卡回到额外卡组，那之后，可以把那特殊召唤。
local s,id,o=GetID()
-- 初始化并注册3个效果：e1为场地卡通用的允许发动的空效果（自由时点），e2为在场地区发动的起动效果（1回合1次，含特殊召唤，代价丢弃手牌），e3为怪兽卡被破坏时触发的诱发选发效果（回额外卡组并可特殊召唤，可在伤害步骤发动）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次：可以丢弃1张魔法·陷阱卡；从额外卡组把1只2星「具象天使」怪兽特殊召唤，从额外卡组把1只「具象天使」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示的「具象天使」怪兽卡被战斗·效果破坏的场合：可以让自己魔法与陷阱区域的1张原本持有者是自己的「具象天使」怪兽卡回到额外卡组，那之后，可以把那特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.tecon)
	e3:SetTarget(s.tetg)
	e3:SetOperation(s.teop)
	c:RegisterEffect(e3)
end
-- 代价筛选函数：筛选可作为发动代价丢弃的魔法·陷阱卡。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 代价函数：检查手牌中是否存在可丢弃的魔法·陷阱卡，存在则让玩家丢弃1张作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测：检查自己手牌中是否存在至少1张可丢弃的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 支付代价：让玩家从手牌选择并丢弃1张魔法·陷阱卡。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 放置筛选函数：筛选额外卡组中可放置到魔法与陷阱区域的「具象天使」怪兽卡（未被禁止放置，且该区域不存在同名卡）。
function s.setfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 特殊召唤筛选函数：筛选额外卡组中可特殊召唤的2星「具象天使」怪兽，要求有出场空格，且当sp2为真时还要求额外卡组中另外存在可放置到魔法与陷阱区域的「具象天使」怪兽卡。
function s.spfilter(c,e,tp,sp2)
	return c:IsLevel(2) and c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可让该额外卡组怪兽特殊召唤出场的空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 当sp2为真时，额外要求额外卡组中存在除该卡以外可放置到魔法与陷阱区域的「具象天使」怪兽卡（即还能执行后续的放置处理）。
		and (not sp2 or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,c,tp))
end
-- 目标函数：发动条件为额外卡组存在可特殊召唤的2星「具象天使」怪兽且魔法与陷阱区域有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在满足条件（可特殊召唤且还能放置1张到魔陷区）的2星「具象天使」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
		-- 并检查自己的魔法与陷阱区域是否存在空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息：本效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：若能执行完整处理（特召后还能放置），则先特殊召唤1只2星「具象天使」怪兽，再从额外卡组选择1张「具象天使」怪兽卡放置到魔法与陷阱区域并使其当作永续魔法卡；否则仅进行特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断额外卡组中是否存在可特殊召唤且还能完成放置处理的2星「具象天使」怪兽，据此决定是否进行放置处理。
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
		-- 向玩家提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的2星「具象天使」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,true)
		-- 若成功选中，则将该怪兽以表侧表示特殊召唤到自己场上。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 特殊召唤成功后，若自己的魔法与陷阱区域已没有空位，则不再进行放置处理。
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			-- 向玩家提示：请选择要放置到场上的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 让玩家从额外卡组选择1张可放置的「具象天使」怪兽卡。
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			local tc=sg:GetFirst()
			if tc then
				-- 把该卡以表侧表示移动放置到自己的魔法与陷阱区域。
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
		end
	else
		-- 向玩家提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的2星「具象天使」怪兽（此时不要求还能执行放置处理）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 触发筛选函数：筛选原本在自己场上以表侧表示存在、被战斗或效果破坏的「具象天使」怪兽卡。
function s.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and c:IsPreviousSetCard(0x1e2)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动条件：被破坏的卡中存在满足条件的「具象天使」怪兽卡，且其中不包含此卡自身。
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 回卡组筛选函数：筛选自己魔法与陷阱区域表侧表示、原本持有者是自己且能回到额外卡组的「具象天使」怪兽卡。
function s.tefilter(c,tp)
	return c:IsSetCard(0x1e2) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
		and c:IsAbleToExtra() and c:IsFaceup() and c:GetOwner()==tp
end
-- 目标函数：发动条件为自己的魔法与陷阱区域存在满足条件的「具象天使」怪兽卡，并设置回额外卡组的操作信息。
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否存在至少1张满足条件的「具象天使」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tefilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	-- 获取自己魔法与陷阱区域中所有满足条件的「具象天使」怪兽卡。
	local g=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_SZONE,0,nil,tp)
	-- 设置操作信息：本效果将把其中1张卡回到额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果处理函数：让玩家选择魔法与陷阱区域1张「具象天使」怪兽卡回到额外卡组，成功后再询问玩家是否将那张卡特殊召唤，选择是则将其特殊召唤。
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己的魔法与陷阱区域1张满足条件的「具象天使」怪兽卡。
	local sg=Duel.SelectMatchingCard(tp,s.tefilter,tp,LOCATION_SZONE,0,1,1,nil,tp)
	if sg:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画并记录。
		Duel.HintSelection(sg)
		-- 将选中的卡以效果原因回到其持有者的额外卡组，成功则继续后续处理。
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			local tc=sg:GetFirst()
			if tc:IsLocation(LOCATION_EXTRA)
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 检查自己场上是否存在可让该额外卡组怪兽特殊召唤出场的空格。
				and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
				-- 询问玩家是否将那张卡特殊召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使特殊召唤与回到额外卡组视为不同时处理（对应原文「那之后」）。
				Duel.BreakEffect()
				-- 将该怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
