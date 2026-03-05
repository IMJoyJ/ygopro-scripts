--異次元ジェット・アイアン号
-- 效果：
-- 这张卡不能通常召唤。从自己的手卡·场上把「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只送去墓地的场合可以特殊召唤。此外，可以把自己场上的这张卡解放，选择自己墓地的「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只特殊召唤。
function c15574615.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己的手卡·场上把「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15574615.spcon)
	e1:SetTarget(c15574615.sptg)
	e1:SetOperation(c15574615.spop)
	c:RegisterEffect(e1)
	-- 可以把自己场上的这张卡解放，选择自己墓地的「异次元超能人·星斗罗宾」「野兽战士 豹人」「凤王兽 铠楼罗」「铁巨人 大铁锤」各1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15574615,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c15574615.cost)
	e2:SetTarget(c15574615.target)
	e2:SetOperation(c15574615.operation)
	c:RegisterEffect(e2)
end
-- 创建一个用于检查是否满足特殊召唤条件的函数数组，该条件为是否包含指定的4张卡片各1只。
c15574615.spchecks=aux.CreateChecks(Card.IsCode,{80208158,16796157,43791861,79185500})
-- 定义一个过滤函数，用于筛选手牌或场上的指定4张卡片，这些卡片可以作为送去墓地的代价。
function c15574615.spcostfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		and c:IsCode(80208158,16796157,43791861,79185500)
end
-- 判断是否满足特殊召唤的条件，即手牌或场上的卡片中是否包含指定的4张卡片各1只。
function c15574615.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家手牌和场上的所有符合条件的卡片组。
	local g=Duel.GetMatchingGroup(c15574615.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 检查该卡片组是否满足特殊召唤条件，即是否包含指定的4张卡片各1只。
	return g:CheckSubGroupEach(c15574615.spchecks,aux.mzctcheck,tp)
end
-- 设置特殊召唤的处理目标，选择满足条件的卡片组并将其标记为处理对象。
function c15574615.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家手牌和场上的所有符合条件的卡片组。
	local g=Duel.GetMatchingGroup(c15574615.spcostfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 向玩家提示选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡片组中选择满足特殊召唤条件的子组。
	local sg=g:SelectSubGroupEach(tp,c15574615.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的处理操作，将标记的卡片组送去墓地。
function c15574615.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定的卡片组以特殊召唤的原因送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义效果的发动代价，需要解放自身作为代价。
function c15574615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义一个过滤函数，用于筛选墓地中的指定4张卡片，这些卡片可以被特殊召唤。
function c15574615.spfilter(c,e,tp)
	return c:IsCode(80208158,16796157,43791861,79185500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 设置效果的目标，判断是否满足特殊召唤的条件，包括是否受到青眼精灵龙效果影响、是否有足够的怪兽区空位以及是否满足特殊召唤条件。
function c15574615.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家墓地中所有符合条件的卡片组。
	local g=Duel.GetMatchingGroup(c15574615.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区空位来容纳4只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		and g:CheckSubGroupEach(c15574615.spchecks)
	end
	-- 向玩家提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroupEach(tp,c15574615.spchecks)
	-- 设置当前处理的连锁的目标卡片为选择的卡片组。
	Duel.SetTargetCard(sg)
	-- 设置当前处理的连锁的操作信息，包括特殊召唤的卡片数量和位置。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,4,0,0)
end
-- 执行效果的处理操作，检查是否受到青眼精灵龙效果影响，并将目标卡片特殊召唤。
function c15574615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 从当前连锁中获取目标卡片组，并筛选出与当前效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取玩家场上可用的怪兽区空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()>ft then return end
	-- 将指定的卡片组以特殊召唤的方式召唤到场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
