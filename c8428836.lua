--冥占術の儀式
-- 效果：
-- 「占术姬」仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从自己的手卡·墓地把1只「占术姬」仪式怪兽表侧攻击表示或者里侧守备表示仪式召唤。
-- ②：自己场上有「占术姬」仪式怪兽存在的场合，自己·对方的准备阶段把墓地的这张卡除外才能发动。从卡组把仪式怪兽以外的1只「占术姬」怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①效果（卡片发动时的仪式召唤效果）和②效果（墓地诱发效果）。
function s.initial_effect(c)
	-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从自己的手卡·墓地把1只「占术姬」仪式怪兽表侧攻击表示或者里侧守备表示仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「占术姬」仪式怪兽存在的场合，自己·对方的准备阶段把墓地的这张卡除外才能发动。从卡组把仪式怪兽以外的1只「占术姬」怪兽里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(s.spcon)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：是否为「占术姬」卡片。
function s.filter(c,e,tp)
	return c:IsSetCard(0xcc)
end
-- 仪式召唤的过滤条件：检查卡片是否为仪式怪兽、是否满足「占术姬」过滤条件、是否能以表侧攻击表示或里侧守备表示特殊召唤，并检查是否有合法的解放素材。
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	-- 设置全局附加检查函数，用于校验仪式素材的等级合计是否大于或等于目标怪兽的等级。
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	-- 检查是否存在满足仪式召唤条件的解放素材组合。
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	-- 清空全局附加检查函数，避免影响后续的其他检查。
	aux.GCheckAdditional=nil
	return res
end
-- ①效果的发动准备：检查手卡·墓地是否存在可以进行仪式召唤的「占术姬」仪式怪兽，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用于仪式召唤的素材卡片组（包含手卡和场上）。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 检查手卡·墓地是否存在至少1只满足仪式召唤条件的「占术姬」仪式怪兽。
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	end
	-- 设置连锁的操作信息：从手卡或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的效果处理：选择1只仪式怪兽，选择并解放等级合计在仪式怪兽等级以上的素材，将该仪式怪兽表侧攻击表示或里侧守备表示特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用于仪式召唤的素材卡片组。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只满足仪式召唤条件的「占术姬」仪式怪兽（受「王家长眠之谷」影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置全局附加检查函数，用于校验所选解放素材的等级合计是否大于或等于该仪式怪兽的等级。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择用于仪式召唤的解放素材组合。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清空全局附加检查函数。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果，使后续的特殊召唤处理与解放素材不视为同时处理。
		Duel.BreakEffect()
		-- 将该仪式怪兽以仪式召唤的方式，表侧攻击表示或里侧守备表示特殊召唤。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0
			and tc:IsFacedown() then
			-- 若以里侧守备表示特殊召唤，则让对方玩家确认该卡。
			Duel.ConfirmCards(1-tp,tc)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：自己场上表侧表示的「占术姬」仪式怪兽。
function s.rtfilter(c)
	return c:IsSetCard(0xcc) and c:IsType(TYPE_RITUAL) and c:IsFaceup()
end
-- ②效果的发动条件：自己场上有「占术姬」仪式怪兽存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「占术姬」仪式怪兽。
	return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中仪式怪兽以外的、可以里侧守备表示特殊召唤的「占术姬」怪兽。
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_RITUAL)
		and c:IsSetCard(0xcc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动准备：检查怪兽区域是否有空位，以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「占术姬」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1只仪式怪兽以外的「占术姬」怪兽，里侧守备表示特殊召唤，并让对方确认。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只仪式怪兽以外的「占术姬」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选定的怪兽以里侧守备表示特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 让对方玩家确认特殊召唤的里侧表示怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
