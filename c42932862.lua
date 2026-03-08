--冥占術姫タロットレイス
-- 效果：
-- 「冥占术的仪式」降临。这张卡用仪式召唤以及「圣占术姬 塔罗光巫女」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只反转怪兽里侧守备表示特殊召唤。
-- ②：自己·对方回合，可以从以下效果选择1个发动。
-- ●选自己场上的里侧表示怪兽任意数量变成表侧守备表示。
-- ●选自己场上的表侧表示怪兽任意数量变成里侧守备表示。
local s,id,o=GetID()
-- 初始化卡片效果，启用仪式召唤限制并注册两个效果：①反转时特殊召唤；②速攻时改变表示形式
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：用仪式召唤以及「圣占术姬 塔罗光巫女」的效果才能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过仪式召唤方式特殊召唤
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 效果原文：这张卡反转的场合才能发动。从卡组把1只反转怪兽里侧守备表示特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果原文：自己·对方回合，可以从以下效果选择1个发动。●选自己场上的里侧表示怪兽任意数量变成表侧守备表示。●选自己场上的表侧表示怪兽任意数量变成里侧守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_STANDBY_PHASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于判断卡组中是否存在可特殊召唤的反转怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足特殊召唤条件：场上是否有空位且卡组中是否存在满足条件的反转怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的反转怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤一张反转怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：选择并特殊召唤一张反转怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的反转怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认被特殊召唤的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤函数：用于判断场上是否存在可改变表示形式的表侧怪兽
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置改变表示形式效果的处理函数：选择并处理改变表示形式的操作
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	-- 获取场上所有表侧表示且可变为里侧表示的怪兽
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 or #mg>0 end
	local op=0
	if #g>0 and #mg>0 then
		-- 提示玩家选择改变表示形式的选项：里侧变表侧/表侧变里侧
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"里侧变成表侧/表侧变成里侧"
	elseif #g>0 then
		-- 提示玩家选择改变表示形式的选项：里侧变表侧
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"里侧变成表侧"
	else
		-- 提示玩家选择改变表示形式的选项：表侧变里侧
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"表侧变成里侧"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_POSITION)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	end
	-- 设置连锁操作信息：准备改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 执行改变表示形式操作：根据选择的选项改变场上怪兽的表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	-- 获取场上所有表侧表示且可变为里侧表示的怪兽
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if e:GetLabel()==0 then
		if g:GetCount()>0 then
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=g:Select(tp,1,g:GetCount(),nil)
			if sg:GetCount()>0 then
				-- 显示被选中的怪兽
				Duel.HintSelection(sg)
				-- 将选中的怪兽变为表侧守备表示
				Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
			end
		end
	else
		if mg:GetCount()>0 then
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg1=mg:Select(tp,1,mg:GetCount(),nil)
			if sg1:GetCount()>0 then
				-- 显示被选中的怪兽
				Duel.HintSelection(sg1)
				-- 将选中的怪兽变为里侧守备表示
				Duel.ChangePosition(sg1,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
