--ワーム・クィーン
-- 效果：
-- 这张卡可以把1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。1回合1次，可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，解放怪兽的等级以下的1只名字带有「异虫」的爬虫类族怪兽从自己卡组特殊召唤。
function c81254059.initial_effect(c)
	-- 这张卡可以把1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81254059,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c81254059.otcon)
	e1:SetOperation(c81254059.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，解放怪兽的等级以下的1只名字带有「异虫」的爬虫类族怪兽从自己卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81254059,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c81254059.spcost)
	e2:SetTarget(c81254059.sptg)
	e2:SetOperation(c81254059.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：名字带有「异虫」的爬虫类族怪兽（若在场上则必须表侧表示）。
function c81254059.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足用1只怪兽解放进行上级召唤的条件。
function c81254059.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有满足条件的可用作解放的「异虫」爬虫类族怪兽。
	local mg=Duel.GetMatchingGroup(c81254059.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 自身等级在7星以上、所需最少祭品数不大于1，且场上存在至少1只可解放的特定怪兽。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行用1只怪兽解放进行上级召唤的操作。
function c81254059.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上所有满足条件的可用作解放的「异虫」爬虫类族怪兽。
	local mg=Duel.GetMatchingGroup(c81254059.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 玩家选择1只用于上级召唤的解放怪兽。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽作为上级召唤的祭品。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤作为解放代价的怪兽：名字带有「异虫」的爬虫类族怪兽，且卡组中存在等级在其以下、可特殊召唤的「异虫」爬虫类族怪兽。
function c81254059.costfilter(c,e,tp,ft)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在等级在被解放怪兽等级以下的、可特殊召唤的「异虫」爬虫类族怪兽。
		and Duel.IsExistingMatchingCard(c81254059.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤卡组中满足特殊召唤条件的、等级在指定数值以下的「异虫」爬虫类族怪兽。
function c81254059.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsLevelBelow(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的代价：解放自己场上1只名字带有「异虫」的爬虫类族怪兽，并记录其等级。
function c81254059.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上怪兽区域的空位数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查阶段：判断是否能腾出怪兽区域，且场上是否存在至少1只满足代价过滤条件的可解放怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c81254059.costfilter,1,nil,e,tp,ft) end
	-- 玩家选择1只满足条件的怪兽准备解放。
	local sg=Duel.SelectReleaseGroup(tp,c81254059.costfilter,1,1,nil,e,tp,ft)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 解放选中的怪兽作为发动效果的代价。
	Duel.Release(sg,REASON_COST)
end
-- 效果发动的目标：确认效果可行性并设置特殊召唤的操作信息。
function c81254059.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只等级在解放怪兽等级以下的「异虫」爬虫类族怪兽特殊召唤。
function c81254059.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只等级在解放怪兽等级以下的「异虫」爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c81254059.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
