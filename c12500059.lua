--暁天使カムビン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有天使族怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把包含这张卡的自己场上的天使族怪兽任意数量解放才能发动（这个效果发动的回合，自己不是天使族怪兽不能特殊召唤）。把持有和解放的怪兽的等级合计相同等级的1只天使族怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有天使族怪兽的场合才能发动。这张卡从手卡特殊召唤。
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
	-- ②：把包含这张卡的自己场上的天使族怪兽任意数量解放才能发动（这个效果发动的回合，自己不是天使族怪兽不能特殊召唤）。把持有和解放的怪兽的等级合计相同等级的1只天使族怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 设置一个用于记录特殊召唤次数的自定义计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，仅统计天使族怪兽
function s.counterfilter(c)
	return c:IsRace(RACE_FAIRY)
end
-- 过滤函数，用于判断场上是否存在非天使族或里侧表示的怪兽
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_FAIRY)
end
-- 效果发动条件函数，判断是否满足①效果发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有怪兽或只有天使族怪兽，则满足①效果发动条件
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的处理目标函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果发动的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查解放组是否满足等级要求的辅助函数
function s.rcheck(g,tp,lv,ec)
	-- 判断解放组的等级总和是否等于目标等级
	return g:GetSum(Card.GetLevel)==lv and Duel.GetMZoneCount(tp,g+ec)>0
		-- 检查是否能通过指定的解放组进行解放
		and Duel.CheckReleaseGroupEx(tp,Auxiliary.IsInGroup,#g,REASON_COST,false,nil,g)
end
-- 过滤函数，用于筛选可解放的天使族怪兽
function s.cfilter2(c,tp)
	return c:IsRace(RACE_FAIRY) and c:IsReleasable() and c:IsLevelAbove(1) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤函数，用于筛选可特殊召唤的天使族怪兽
function s.filter(c,e,tp,lvt)
	local lv=c:GetLevel()
	return lvt[lv] and lv>0 and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理费用函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 检查是否已使用过②效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 设置②效果发动时的限制，禁止非天使族怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册限制效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数，禁止非天使族怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- ②效果的处理目标函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsReleasable() or not c:IsRace(RACE_FAIRY) then return false end
	local clv=c:GetLevel()
	-- 获取可解放的天使族怪兽组
	local rg=Duel.GetReleaseGroup(tp):Filter(s.cfilter2,c,tp)
	local lvt={}
	for lv=clv,12 do
		-- 判断是否可以满足等级要求并进行解放
		if lv==clv and Duel.GetMZoneCount(tp,c)>0 or rg:CheckSubGroup(s.rcheck,1,99,tp,lv-clv,c) then
			lvt[lv]=true
		end
	end
	-- 筛选满足等级要求的天使族怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp,lvt)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return #g>0
	end
	local alvt={}
	for lv=1,12 do
		if lvt[lv] and g:IsExists(Card.IsLevel,1,nil,lv) then
			alvt[#alvt+1]=lv
		end
	end
	-- 让玩家宣言要特殊召唤的怪兽等级
	local tglv=Duel.AnnounceNumber(tp,table.unpack(alvt))
	if tglv>clv then
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=rg:SelectSubGroup(tp,s.rcheck,false,1,99,tp,tglv-clv,c)+c
		-- 使用额外解放次数
		aux.UseExtraReleaseCount(sg,tp)
		-- 解放指定的怪兽
		Duel.Release(sg,REASON_COST)
	else
		-- 解放自身怪兽
		Duel.Release(c,REASON_COST)
	end
	e:SetLabel(tglv)
	-- 设置②效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 筛选可特殊召唤的天使族怪兽
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足等级要求的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
