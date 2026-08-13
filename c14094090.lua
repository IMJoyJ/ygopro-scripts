--超戦士の儀式
-- 效果：
-- 「混沌战士」仪式怪兽的降临必需。「超战士的仪式」的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把等级合计直到8的怪兽解放，从手卡把1只「混沌战士」仪式怪兽仪式召唤。
-- ②：从自己墓地把这张卡以及1只光属性怪兽和1只暗属性怪兽除外才能发动。从手卡把1只「混沌战士」仪式怪兽无视召唤条件特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c14094090.initial_effect(c)
	-- 为「超战士的仪式」添加仪式召唤效果，素材需为等级合计等于仪式怪兽原本等级的怪兽，且仪式怪兽需满足ritual_filter（「混沌战士」仪式怪兽）。
	aux.AddRitualProcEqual(c,c14094090.ritual_filter)
	-- ②：从自己墓地把这张卡以及1只光属性怪兽和1只暗属性怪兽除外才能发动。从手卡把1只「混沌战士」仪式怪兽无视召唤条件特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,14094090)
	-- 设置②效果的发动条件为“这张卡送去墓地的回合不能发动”，由aux.exccon实现。
	e1:SetCondition(aux.exccon)
	e1:SetCost(c14094090.spcost)
	e1:SetTarget(c14094090.sptg)
	e1:SetOperation(c14094090.spop)
	c:RegisterEffect(e1)
end
-- 定义仪式召唤可用怪兽的过滤条件：必须是仪式怪兽且属于「混沌战士」系列（0x10cf）。
function c14094090.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x10cf)
end
-- 定义代价怪兽的过滤条件：怪兽拥有指定属性（光或暗）且可以作为代价除外。
function c14094090.cfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
-- 效果②发动前检查代价是否成立：自身能除外、墓地存在至少1只光属性和1只暗属性且可作为代价除外的怪兽。
function c14094090.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在至少1只光属性且可作为代价除外的怪兽。
		and Duel.IsExistingMatchingCard(c14094090.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
		-- 检查墓地是否存在至少1只暗属性且可作为代价除外的怪兽。
		and Duel.IsExistingMatchingCard(c14094090.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK) end
	-- 向玩家提示选择要除外的卡（光属性怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只光属性且可作为代价除外的怪兽。
	local g1=Duel.SelectMatchingCard(tp,c14094090.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_LIGHT)
	-- 向玩家提示选择要除外的卡（暗属性怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只暗属性且可作为代价除外的怪兽。
	local g2=Duel.SelectMatchingCard(tp,c14094090.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_DARK)
	g1:Merge(g2)
	g1:AddCard(e:GetHandler())
	-- 将选择的怪兽以及这张卡自身以表侧表示除外，作为发动代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：必须是「混沌战士」仪式怪兽，且可以被无视召唤条件特殊召唤（不检查苏生限制）。
function c14094090.spfilter(c,e,tp)
	return c:IsSetCard(0x10cf) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②发动时确认：自己主要怪兽区有空位，且手牌存在满足特殊召唤条件的「混沌战士」仪式怪兽。
function c14094090.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌是否存在至少1只满足特殊召唤条件的「混沌战士」仪式怪兽。
		and Duel.IsExistingMatchingCard(c14094090.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：从手牌特殊召唤1只怪兽到自己的主要怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②处理时：若主要怪兽区仍有空位，则选择手牌1只「混沌战士」仪式怪兽并无视召唤条件特殊召唤。
function c14094090.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区仍有可用空格，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足条件的「混沌战士」仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,c14094090.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，无视召唤条件。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
