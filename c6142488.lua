--ファーニマル・マウス
-- 效果：
-- 这张卡的效果发动的回合，自己不是「魔玩具」怪兽不能从额外卡组特殊召唤。
-- ①：只在这张卡在场上表侧表示存在才有1次在自己主要阶段才能发动。从卡组把最多2只「毛绒动物·鼠」特殊召唤。
function c6142488.initial_effect(c)
	-- ①：只在这张卡在场上表侧表示存在才有1次在自己主要阶段才能发动。从卡组把最多2只「毛绒动物·鼠」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetCost(c6142488.spcost)
	e1:SetTarget(c6142488.sptg)
	e1:SetOperation(c6142488.spop)
	c:RegisterEffect(e1)
	-- 注册用于检测是否从额外卡组特殊召唤了「魔玩具」以外怪兽的自定义活动计数器
	Duel.AddCustomActivityCounter(6142488,ACTIVITY_SPSUMMON,c6142488.counterfilter)
end
-- 过滤函数：检测特殊召唤的怪兽是否为表侧表示的「魔玩具」怪兽或并非从额外卡组特殊召唤
function c6142488.counterfilter(c)
	return c:IsSetCard(0xad) and c:IsFaceup() or not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 主要阶段效果的Cost函数，检查本回合是否已特殊召唤过「魔玩具」以外的额外怪兽，并注册本回合不能特殊召唤「魔玩具」以外额外怪兽的誓约效果
function c6142488.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查本回合是否未从额外卡组特殊召唤过「魔玩具」以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(6142488,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不是「魔玩具」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c6142488.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能从额外卡组特殊召唤「魔玩具」以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：限制非「魔玩具」怪兽从额外卡组进行特殊召唤
function c6142488.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xad) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：检测卡片是否为「毛绒动物·鼠」且可以被特殊召唤
function c6142488.filter(c,e,tp)
	return c:IsCode(6142488) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 主要阶段效果的Target函数，检查怪兽区域空位以及卡组中是否存在可特殊召唤的「毛绒动物·鼠」
function c6142488.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查玩家场上的怪兽区域是否还有空余的格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组中是否存在至少1张可以特殊召唤的「毛绒动物·鼠」
		and Duel.IsExistingMatchingCard(c6142488.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 主要阶段效果的Operation函数，从卡组特殊召唤最多2只「毛绒动物·鼠」
function c6142488.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上主要怪兽区域的可召唤空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择需要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择最多为可用空位格数且符合条件的「毛绒动物·鼠」
	local g=Duel.SelectMatchingCard(tp,c6142488.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
