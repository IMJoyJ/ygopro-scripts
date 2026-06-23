--暁天使カムビン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有天使族怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把包含这张卡的自己场上的天使族怪兽任意数量解放才能发动（这个效果发动的回合，自己不是天使族怪兽不能特殊召唤）。把持有和解放的怪兽的等级合计相同等级的1只天使族怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤，②场上解放特召卡组怪兽，并添加特殊召唤限制的计数器
function s.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有天使族怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
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
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 设置玩家进行特殊召唤的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤条件：表侧表示的天使族怪兽
function s.counterfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsFaceup()
end
-- 过滤条件：里侧表示怪兽或非天使族怪兽
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_FAIRY)
end
-- 效果①的发动条件：自己场上没有怪兽或者只有天使族怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上不存在里侧表示怪兽和非天使族怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的靶标（Target）函数：检查怪兽区域是否有空位及自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，确认自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将自身在自己场上表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 解放合法性检查：检查怪兽等级合计是否等于目标等级、解放后是否有可用怪兽区域以及是否满足解放条件
function s.rcheck(g,tp,lv,ec)
	-- 确认怪兽组的等级合计等于目标等级，且这些怪兽离开后有可用的怪兽区域
	return g:GetSum(Card.GetLevel)==lv and Duel.GetMZoneCount(tp,g+ec)>0
		-- 检查选中的怪兽组是否全都可以被解放
		and Duel.CheckReleaseGroupEx(tp,Auxiliary.IsInGroup,#g,REASON_COST,false,nil,g)
end
-- 过滤条件：可解放的、等级1以上的天使族怪兽（若在对方场上则须表侧表示）
function s.cfilter2(c,tp)
	return c:IsRace(RACE_FAIRY) and c:IsReleasable() and c:IsLevelAbove(1) and (c:IsControler(tp) or c:IsFaceup())
end
-- 过滤条件：卡组中等级符合要求且可特殊召唤的天使族怪兽
function s.filter(c,e,tp,lvt)
	local lv=c:GetLevel()
	return lvt[lv] and lv>0 and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的代价（Cost）函数：进行特召限制检测，并注册本回合不能特召非天使族怪兽的限制效果
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 在chk==0时，检查本回合是否未特殊召唤过非天使族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ②：把包含这张卡的自己场上的天使族怪兽任意数量解放才能发动（这个效果发动的回合，自己不是天使族怪兽不能特殊召唤）。把持有和解放的怪兽的等级合计相同等级的1只天使族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 为玩家注册不能特殊召唤非天使族怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特召限制条件：不能特殊召唤非天使族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- 效果②的靶标（Target）函数：计算可特召的怪兽等级，让玩家宣言特召等级并选择被解放的天使族怪兽，设置特召操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsReleasable() or not c:IsRace(RACE_FAIRY) then return false end
	local clv=c:GetLevel()
	-- 筛选自己场上可作为解放代价的天使族怪兽（不包含自身）
	local rg=Duel.GetReleaseGroup(tp):Filter(s.cfilter2,c,tp)
	local lvt={}
	for lv=clv,12 do
		-- 判断仅解放自身即可特召，或者是否存在其他天使族怪兽的解放组合能凑齐等级差
		if lv==clv and Duel.GetMZoneCount(tp,c)>0 or rg:CheckSubGroup(s.rcheck,1,99,tp,lv-clv,c) then
			lvt[lv]=true
		end
	end
	-- 从卡组中获取所有满足条件且等级在可用列表内的天使族怪兽
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
	-- 让玩家选择并宣言要特殊召唤的怪兽等级
	local tglv=Duel.AnnounceNumber(tp,table.unpack(alvt))
	if tglv>clv then
		-- 提示玩家选择要解放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=rg:SelectSubGroup(tp,s.rcheck,false,1,99,tp,tglv-clv,c)+c
		-- 处理可能适用的代替解放（如暗影敌托邦等效果的代替解放数）
		aux.UseExtraReleaseCount(sg,tp)
		-- 将选中的怪兽组（包含自身）解放
		Duel.Release(sg,REASON_COST)
	else
		-- 仅将这张卡自身解放
		Duel.Release(c,REASON_COST)
	end
	e:SetLabel(tglv)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中等级等于目标等级且可特殊召唤的天使族怪兽
function s.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理：从卡组中选择1只符合宣言等级的天使族怪兽在场上特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与宣言等级相同、可特殊召唤的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
