--スカーレッド・ゾーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，对方把卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：以自己的除外状态的1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个诱发效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载着「红莲魔龙」（卡号70902743）
	aux.AddCodeList(c,70902743)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果①：对方把卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"场上的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- 效果②：以自己的除外状态的1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 用于检测己方场上的「红莲魔龙」或其同调怪兽是否存在
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(70902743) or c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_MZONE)
		-- 判断场上存在的同调怪兽是否记载着「红莲魔龙」的卡名
		and aux.IsCodeListed(c,70902743))
end
-- 效果①的发动条件：对方发动效果时，且己方场上有「红莲魔龙」或其同调怪兽存在
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上有满足条件的怪兽（即「红莲魔龙」或其同调怪兽）
	return rp==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的目标选择处理，选择场上1张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足效果①的目标选择条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理，对目标卡进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍在连锁中则将其破坏
	if tc:IsRelateToChain() then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 用于筛选除外状态的龙族·暗属性同调怪兽
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择处理，选择除外状态的1只符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查己方是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方除外区是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方提示该效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外状态的1只符合条件的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理，将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍在效果中则将其特殊召唤
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
