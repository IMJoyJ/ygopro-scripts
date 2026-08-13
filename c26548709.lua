--蕾禍ノ矢筈天牛
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让自己的除外状态的1只昆虫族·植物族·爬虫类族怪兽回到卡组最下面，从手卡特殊召唤。
-- ②：这张卡作为「蕾祸」连接怪兽的连接素材送去墓地的场合，以除「蕾祸之矢筈天牛」外的自己墓地1只4星以下的昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的两个效果：e1是手牌规则特殊召唤效果（①效果，1回合1次），e2是作为「蕾祸」连接素材送墓后发动的墓地特召效果（②效果，1回合1次）。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让自己的除外状态的1只昆虫族·植物族·爬虫类族怪兽回到卡组最下面，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：这张卡作为「蕾祸」连接怪兽的连接素材送去墓地的场合，以除「蕾祸之矢筈天牛」外的自己墓地1只4星以下的昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤昆虫族·植物族·爬虫类族怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义①效果所需的除外区素材筛选条件：该卡须为表侧表示、属于昆虫族·植物族·爬虫类族之一，并且可以作为代价返回卡组。
function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeckAsCost()
end
-- ①效果（规则特殊召唤）的召唤手续条件：当这张卡在手牌进行规则特殊召唤时，若己方主怪兽区有空位，且除外区存在至少1张符合条件的怪兽，则可以进行这次特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认己方主要怪兽区域存在空位，可供这张卡特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认己方除外区存在至少1张满足spfilter的怪兽，可作为①效果返回卡组的代价。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil)
end
-- ①效果的代价处理：从己方除外区选择1只符合条件的怪兽并展示，将其送回持有者卡组最下面，完成特殊召唤所需手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 向操作玩家显示“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从己方除外区选择1张满足spfilter的怪兽作为返回卡组的代价。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 为选中的卡播放被选择对象的动画，让玩家确认选择结果。
	Duel.HintSelection(g)
	-- 将选中的卡以代价（REASON_COST）送回持有者卡组最下面（seq=1）。
	Duel.SendtoDeck(g,nil,1,REASON_COST)
end
-- ②效果的触发条件：这张卡在墓地，且是作为连接召唤的素材被送去墓地，并且导致其进入墓地的连接怪兽的卡名含有「蕾祸」字段。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x1ab)
end
-- ②效果可选择对象的过滤条件：不是这张卡自身，等级4以下，属于昆虫族·植物族·爬虫类族之一，且能被当前效果以表侧守备表示特殊召唤。
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsLevelBelow(4) and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动处理：根据连锁对象校验合法性，确认存在合法对象后，从自己墓地选择1只符合条件的怪兽作为效果对象，并登记特殊召唤操作。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足spfilter2的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合spfilter2条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁操作信息：将特殊召唤1只怪兽的信息写入，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得发动时选择的对象怪兽，若其仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上，不检查召唤条件，也不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
