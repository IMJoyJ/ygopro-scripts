--無限光アイン・ソフ・オウル
-- 效果：
-- 把自己的魔法与陷阱区域1张表侧表示的「无限械」送去墓地才能把这张卡发动。
-- ①：这张卡不会被对方的效果破坏。
-- ②：自己场上的「时械神」怪兽不会成为效果的对象，双方不能让场上的「时械神」怪兽回到卡组。
-- ③：1回合1次，自己场上没有怪兽存在的场合才能发动。从自己的手卡·卡组·墓地各把最多1只卡名不同的「时械神」怪兽无视召唤条件特殊召唤。
function c72883039.initial_effect(c)
	-- 把自己的魔法与陷阱区域1张表侧表示的「无限械」送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c72883039.actcost)
	e1:SetTarget(c72883039.acttg)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	-- 设置该卡不会被对方的效果破坏
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：自己场上的「时械神」怪兽不会成为效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤自己场上字段为「时械神」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4a))
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 双方不能让场上的「时械神」怪兽回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_TO_DECK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c72883039.tdtg)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己场上没有怪兽存在的场合才能发动。从自己的手卡·卡组·墓地各把最多1只卡名不同的「时械神」怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(72883039,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c72883039.spcon)
	e5:SetCost(c72883039.spcost)
	e5:SetTarget(c72883039.sptg)
	e5:SetOperation(c72883039.spop)
	c:RegisterEffect(e5)
end
-- 过滤自己魔陷区表侧表示的「无限械」且能送去墓地的卡
function c72883039.acfilter(c)
	return c:IsFaceup() and c:IsCode(36894320) and c:IsAbleToGraveAsCost()
end
-- 卡片发动时的Cost处理：将自己魔陷区1张表侧表示的「无限械」送去墓地
function c72883039.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在可作为Cost送去墓地的「无限械」
	if chk==0 then return Duel.IsExistingMatchingCard(c72883039.acfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己魔陷区1张表侧表示的「无限械」
	local g=Duel.SelectMatchingCard(tp,c72883039.acfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 卡片发动时的效果处理：若满足条件，可选择在发动时直接连带发动③的效果
function c72883039.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if c72883039.spcon(e,tp,eg,ep,ev,re,r,rp)
		and c72883039.spcost(e,tp,eg,ep,ev,re,r,rp,0)
		and c72883039.sptg(e,tp,eg,ep,ev,re,r,rp,0)
		-- 询问玩家是否在发动这张卡时直接发动其特殊召唤的效果
		and Duel.SelectYesNo(tp,94) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(c72883039.spop)
		c72883039.spcost(e,tp,eg,ep,ev,re,r,rp,1)
		c72883039.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
-- 过滤场上的「时械神」怪兽，作为不能回到卡组效果的影响对象
function c72883039.tdtg(e,c)
	return c:IsSetCard(0x4a) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的发动条件：自己场上没有怪兽存在
function c72883039.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 特殊召唤效果的Cost：1回合1次，给这张卡添加已发动效果的Flag标记
function c72883039.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(72883039)==0 end
	c:RegisterFlagEffect(72883039,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤手卡·卡组·墓地中可以无视召唤条件特殊召唤的「时械神」怪兽
function c72883039.spfilter(c,e,tp)
	return c:IsSetCard(0x4a) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的Target：检查怪兽区域空位及是否存在可特召的「时械神」怪兽，并设置特殊召唤的操作信息
function c72883039.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·卡组·墓地是否存在至少1只满足条件的「时械神」怪兽
		and Duel.IsExistingMatchingCard(c72883039.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从手卡·卡组·墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤卡片组的选择条件：卡名各不相同，且每张卡来自不同的区域（手卡、卡组、墓地各最多1只）
function c72883039.gselect(g)
	-- 检查所选卡片组是否卡名互不相同，且所选卡片的来源区域数量等于卡片总数（即每个区域最多选1张）
	return aux.dncheck(g) and g:GetClassCount(Card.GetLocation)==#g
end
-- 特殊召唤效果的处理：从手卡·卡组·墓地各选择最多1只卡名不同的「时械神」怪兽无视召唤条件特殊召唤
function c72883039.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡·卡组·墓地中满足条件且不受「王家长眠之谷」影响的「时械神」怪兽集合
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c72883039.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c72883039.gselect,false,1,math.min(ft,3))
	if sg then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end
