--冥占術姫タロットレイス
-- 效果：
-- 「冥占术的仪式」降临。这张卡用仪式召唤以及「圣占术姬 塔罗光巫女」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只反转怪兽里侧守备表示特殊召唤。
-- ②：自己·对方回合，可以从以下效果选择1个发动。
-- ●选自己场上的里侧表示怪兽任意数量变成表侧守备表示。
-- ●选自己场上的表侧表示怪兽任意数量变成里侧守备表示。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤限制效果、反转时从卡组特殊召唤效果以及自由时点改变表示形式效果
function s.initial_effect(c)
	-- 在卡片上记录「冥占术的仪式」与「圣占术姬 塔罗光巫女」的卡名信息
	aux.AddCodeList(c,8428836,94997874)
	c:EnableReviveLimit()
	-- 这张卡用仪式召唤以及「圣占术姬 塔罗光巫女」的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡特殊召唤的规则限制为仪式召唤（或特定的卡片效果召唤）
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：这张卡反转的场合才能发动。从卡组把1只反转怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下效果选择1个发动。●选自己场上的里侧表示怪兽任意数量变成表侧守备表示。●选自己场上的表侧表示怪兽任意数量变成里侧守备表示。
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
-- 过滤卡组中可以被特殊召唤的反转怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 反转特殊召唤效果的目标检查与操作信息设置函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的反转怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置从卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 反转特殊召唤效果的效果处理激活函数，执行选择怪兽里侧特殊召唤并让对方确认的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有空余的怪兽区域，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己选择卡组中的1只符合条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将里侧特殊召唤的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤场上表侧表示且可以变成里侧表示的怪兽的过滤条件
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 改变表示形式效果的目标检查与选项选择函数
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有的里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	-- 获取自己场上所有可以变成里侧守备表示的表侧表示怪兽
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 or #mg>0 end
	local op=0
	if #g>0 and #mg>0 then
		-- 让玩家选择“里侧变成表侧守备表示”或“表侧变成里侧守备表示”
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))  --"里侧变成表侧/表侧变成里侧"
	elseif #g>0 then
		-- 当仅有里侧怪兽时，让玩家选择“里侧变成表侧守备表示”的选项
		op=Duel.SelectOption(tp,aux.Stringid(id,2))  --"里侧变成表侧"
	else
		-- 当仅有表侧怪兽时，让玩家选择“表侧变成里侧守备表示”的选项
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+1  --"表侧变成里侧"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_POSITION)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	end
	-- 设置改变卡片表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 改变表示形式效果的效果处理激活函数，根据所选操作将怪兽形式变更
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的里侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
	-- 获取自己场上所有可以变成里侧守备表示的表侧表示怪兽
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if e:GetLabel()==0 then
		if g:GetCount()>0 then
			-- 提示玩家选择要改变表示形式的里侧怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg=g:Select(tp,1,g:GetCount(),nil)
			if sg:GetCount()>0 then
				-- 显示被选中里侧怪兽的动画效果并记录
				Duel.HintSelection(sg)
				-- 将选中的里侧怪兽变成表侧守备表示
				Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
			end
		end
	else
		if mg:GetCount()>0 then
			-- 提示玩家选择要改变表示形式的表侧怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			local sg1=mg:Select(tp,1,mg:GetCount(),nil)
			if sg1:GetCount()>0 then
				-- 显示被选中表侧怪兽的动画效果并记录
				Duel.HintSelection(sg1)
				-- 将选中的表侧怪兽变成里侧守备表示
				Duel.ChangePosition(sg1,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
