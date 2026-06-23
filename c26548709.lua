--蕾禍ノ矢筈天牛
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让自己的除外状态的1只昆虫族·植物族·爬虫类族怪兽回到卡组最下面，从手卡特殊召唤。
-- ②：这张卡作为「蕾祸」连接怪兽的连接素材送去墓地的场合，以除「蕾祸之矢筈天牛」外的自己墓地1只4星以下的昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②的效果
function s.initial_effect(c)
	-- ①：这张卡可以让自己的除外状态的1只昆虫族·植物族·爬虫类族怪兽回到卡组最下面，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「蕾祸」连接怪兽的连接素材送去墓地的场合，以除「蕾祸之矢筈天牛」外的自己墓地1只4星以下的昆虫族·植物族·爬虫类族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
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
-- 过滤函数，用于判断除外区是否有满足条件的昆虫族·植物族·爬虫类族怪兽
function s.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsAbleToDeckAsCost()
end
-- 判断是否满足①效果的特殊召唤条件
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手卡特殊召唤时场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断除外区是否有满足条件的昆虫族·植物族·爬虫类族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil)
end
-- 处理①效果的特殊召唤操作，选择除外区的怪兽返回卡组
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外区满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 显示选中的怪兽被选为对象
	Duel.HintSelection(g)
	-- 将选中的怪兽送回卡组最下面
	Duel.SendtoDeck(g,nil,1,REASON_COST)
end
-- 判断是否满足②效果的发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0x1ab)
end
-- 过滤函数，用于判断墓地是否有满足条件的昆虫族·植物族·爬虫类族怪兽
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsLevelBelow(4) and c:IsRace(RACE_INSECT+RACE_PLANT+RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置②效果的发动目标
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查是否有满足条件的墓地怪兽可作为对象
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地满足条件的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理②效果的特殊召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
