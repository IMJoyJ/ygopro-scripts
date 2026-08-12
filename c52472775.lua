--粛声なる祈り
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的光属性怪兽解放，从手卡把1只光属性仪式怪兽仪式召唤。
-- ②：自己场上的表侧表示的光属性仪式怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。从手卡·卡组把「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」的其中1只无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册仪式魔法卡的主效果，包括设置卡名代码列表和仪式召唤程序
function s.initial_effect(c)
	-- 记录该卡与「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」这三张卡有关联
	aux.AddCodeList(c,4810828,56350972,10774240)
	-- 注册等级合计直到变成仪式召唤的怪兽的等级以上为止的仪式召唤程序，使用s.spfilter和s.mfilter作为过滤函数
	aux.AddRitualProcGreater2(c,s.spfilter,nil,nil,s.mfilter)
	-- 创建效果2，用于处理②的效果，当光属性仪式怪兽因对方效果离场时发动
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 设置效果2的发动费用为将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选手卡或场上光属性怪兽的过滤函数，用于仪式召唤条件判断
function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 筛选手卡或场上光属性怪兽的过滤函数，用于仪式召唤祭品条件判断
function s.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 判断离场怪兽是否为光属性仪式怪兽且因对方效果离开的过滤函数
function s.plcfilter(c,tp)
	return c:IsType(TYPE_RITUAL) and c:IsPreviousControler(tp)
		and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetPreviousAttributeOnField()&ATTRIBUTE_LIGHT>0
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 设置效果2的发动条件，当有光属性仪式怪兽因对方效果从场上离开时才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.plcfilter,1,nil,tp)
end
-- 筛选「古圣戴 始龙」「龙姬神 萨菲拉」「肃声之守护者 法理守护者」三张卡并可特殊召唤的过滤函数
function s.filter(c,e,tp)
	return c:IsCode(4810828,56350972,10774240) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果2的发动时点，检查是否有满足条件的卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组中是否存在满足条件的特殊召唤卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要从手牌或卡组特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 设置效果2的发动处理，选择并特殊召唤符合条件的卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以无视召唤条件的方式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
