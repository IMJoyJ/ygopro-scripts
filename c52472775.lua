--粛声なる祈り
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的光属性怪兽解放，从手卡把1只光属性仪式怪兽仪式召唤。
-- ②：自己场上的表侧表示的光属性仪式怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。从手卡·卡组把「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」的其中1只无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化效果：登记卡名关联的三种仪式怪兽；注册仪式召唤效果①；注册②效果的诱发效果（墓地除外特召）
function s.initial_effect(c)
	-- 将「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」登记为这张卡上记载的卡名
	aux.AddCodeList(c,4810828,56350972,10774240)
	-- 为这张卡添加①仪式召唤效果：解放手卡·场上的光属性怪兽，从手卡仪式召唤1只光属性仪式怪兽，素材可用光属性怪兽
	aux.AddRitualProcGreater2(c,s.spfilter,nil,nil,s.mfilter)
	-- ②：自己场上的表侧表示的光属性仪式怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。从手卡·卡组把「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」的其中1只无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 设置②效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 仪式召唤①的仪式怪兽过滤函数：选择光属性怪兽
function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 仪式召唤①的解放素材过滤函数：选择光属性怪兽作为解放素材
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 判定离开场上的光属性仪式怪兽是否满足②触发条件：曾是里侧表侧？具体为仪式、之前控制者是tp、光属性、离场前是表侧光属性、离场原因是对方效果、此前在怪兽区
function s.plcfilter(c,tp)
	return c:IsType(TYPE_RITUAL) and c:IsPreviousControler(tp)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetPreviousAttributeOnField()&ATTRIBUTE_LIGHT>0
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②的发动条件：满足plcfilter的怪兽因对方效果从场上离开时，该效果可以从墓地发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.plcfilter,1,nil,tp)
end
-- 特召目标过滤：必须是「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」其中1只，且可以无视召唤条件特殊召唤
function s.filter(c,e,tp)
	return c:IsCode(4810828,56350972,10774240) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②的发动目标检查：自己主要怪兽区有空位，且手卡·卡组存在符合条件的特召目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②发动时检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ②发动时检查手卡·卡组中是否存在3张指定卡之一且能被特殊召唤的目标
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：要执行特殊召唤，且特殊召唤的来源是卡组（手卡也包含但以卡组位置表示）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若仍存在可用怪兽区，则提示选择要特殊召唤的卡，从手卡·卡组选1张符合条件的怪兽无视召唤条件表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上仍有空格，否则直接结束
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张符合条件的「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上，无视召唤条件且不检查苏生限制
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
