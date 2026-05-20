--鉄の王 ドヴェルグス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「铁界王战 矮人联合王」在自己场上只能有1只表侧表示存在。
-- ②：把自己场上的「王战」怪兽或者机械族怪兽任意数量解放才能发动。把解放数量的和解放的怪兽卡名不同的，「王战」怪兽或者机械族怪兽从手卡守备表示特殊召唤（同名卡最多1张）。这个效果在对方回合也能发动。
function c76382116.initial_effect(c)
	c:SetUniqueOnField(1,0,76382116)
	-- ②：把自己场上的「王战」怪兽或者机械族怪兽任意数量解放才能发动。把解放数量的和解放的怪兽卡名不同的，「王战」怪兽或者机械族怪兽从手卡守备表示特殊召唤（同名卡最多1张）。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76382116,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,76382116)
	e1:SetCost(c76382116.spcost)
	e1:SetTarget(c76382116.sptg)
	e1:SetOperation(c76382116.spop)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可特殊召唤的「王战」怪兽或机械族怪兽，且其卡名不能与传入的解放怪兽卡名相同
function c76382116.spfilter(c,e,tp,...)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_MACHINE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(...)
end
-- 过滤场上可作为解放代价的「王战」怪兽或机械族怪兽（初次检测用），要求其解放后能腾出怪兽区域，且手牌中存在至少1张与其卡名不同的可特殊召唤的对应怪兽
function c76382116.costfilter1(c,e,tp)
	-- 检查该卡是否为「王战」怪兽或机械族怪兽，且其离开场上后能腾出至少1个怪兽区域
	return (c:IsSetCard(0x134) or c:IsRace(RACE_MACHINE)) and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌中是否存在至少1张与该卡卡名不同的、可特殊召唤的「王战」怪兽或机械族怪兽
		and Duel.IsExistingMatchingCard(c76382116.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 过滤场上可作为解放代价的「王战」怪兽或机械族怪兽（实际选择用），要求手牌中存在至少1张与其卡名不同的可特殊召唤的对应怪兽
function c76382116.costfilter2(c,e,tp)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_MACHINE))
		-- 检查手牌中是否存在至少1张与该卡卡名不同的、可特殊召唤的「王战」怪兽或机械族怪兽
		and Duel.IsExistingMatchingCard(c76382116.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 组选函数，用于验证选定的解放怪兽组合是否合法：手牌中必须存在数量充足且卡名互不相同、且与解放怪兽卡名也不同的可特殊召唤怪兽，同时解放后腾出的怪兽区域也必须足够
function c76382116.fselect(g,e,tp)
	local code={}
	-- 遍历选定的解放怪兽卡片组
	for tc in aux.Next(g) do
		table.insert(code,tc:GetCode())
	end
	-- 获取手牌中所有与被解放怪兽卡名都不同的、可特殊召唤的「王战」怪兽或机械族怪兽
	local sg=Duel.GetMatchingGroup(c76382116.spfilter,tp,LOCATION_HAND,0,nil,e,tp,table.unpack(code))
	-- 检查手牌中满足条件的怪兽种类数是否不小于解放数量，且解放这些怪兽后腾出的怪兽区域数量是否足够容纳特殊召唤的怪兽
	if sg:GetClassCount(Card.GetCode)>=g:GetCount() and Duel.GetMZoneCount(tp,g)>=g:GetCount() then
		-- 确认选定的卡片组在规则上是否全部可以被解放
		return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
	else return false end
end
-- 效果发动代价的处理函数，用于选择并解放任意数量的「王战」怪兽或机械族怪兽，并记录被解放怪兽的卡名
function c76382116.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段，确认场上是否存在至少1只满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c76382116.costfilter1,1,nil,e,tp) end
	-- 获取场上所有可解放且满足条件的怪兽卡片组
	local rg=Duel.GetReleaseGroup(tp):Filter(c76382116.costfilter2,nil,e,tp)
	-- 计算将这些怪兽全部解放后，自己场上可用的怪兽区域最大数量
	local ft=Duel.GetMZoneCount(tp,rg)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c76382116.fselect,false,1,ft,e,tp)
	local code={}
	-- 遍历玩家选择准备解放的怪兽卡片组
	for tc in aux.Next(sg) do
		table.insert(code,tc:GetCode())
	end
	e:SetLabel(table.unpack(code))
	-- 适用代替解放等相关效果的次数限制
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的目标确认与信息注册函数
function c76382116.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local code={e:GetLabel()}
	-- 设置特殊召唤的操作信息，指定从手牌特殊召唤与解放数量相同数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#code,tp,LOCATION_HAND)
end
-- 效果处理的函数，从手牌将对应数量且卡名互不相同、且与解放怪兽卡名也不同的怪兽守备表示特殊召唤
function c76382116.spop(e,tp,eg,ep,ev,re,r,rp)
	local code={e:GetLabel()}
	-- 获取当前自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft<#code then return end
	-- 获取手牌中所有与被解放怪兽卡名都不同的、可特殊召唤的「王战」怪兽或机械族怪兽
	local sg=Duel.GetMatchingGroup(c76382116.spfilter,tp,LOCATION_HAND,0,nil,e,tp,table.unpack(code))
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择与解放数量相同、且卡名互不相同的怪兽
	local tg=sg:SelectSubGroup(tp,aux.dncheck,false,#code,#code)
	if tg and tg:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
