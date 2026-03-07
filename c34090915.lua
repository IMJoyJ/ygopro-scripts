--復烙印
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在同一连锁上只能发动1次。
-- ①：光·暗属性怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽回到卡组最下面，自己抽1张。
-- ②：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己墓地1只「深渊之兽」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id=GetID()
-- 注册场地魔法卡的发动效果，使卡能被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 注册一个合并的除外事件监听器，用于监听光·暗属性怪兽被除外的事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- ①：光·暗属性怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽回到卡组最下面，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外的怪兽并抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己墓地1只「深渊之兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤墓地的怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义用于筛选被除外的光·暗属性怪兽的过滤器函数
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_REMOVED)
end
-- 设置效果的发动条件，检查是否有符合条件的除外怪兽且自己可以抽卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,e)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=eg:FilterSelect(tp,s.cfilter,1,1,nil,e)
	-- 设置效果的目标卡
	Duel.SetTargetCard(g)
	-- 设置效果操作信息：将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置效果操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理效果的发动操作，将目标怪兽送回卡组最底端并抽1张卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上或被除外，并将目标卡送回卡组最底端
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		-- 执行抽卡效果
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤效果的发动条件，即对方有怪兽召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义用于筛选墓地中的「深渊之兽」怪兽的过滤器函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x188) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件，检查是否有符合条件的墓地怪兽且未在本连锁使用过该效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有足够的召唤区域且本连锁未使用过该效果
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
		-- 检查是否有符合条件的墓地怪兽可被选择
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 注册一个标识效果，防止本连锁重复发动该效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的「深渊之兽」怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果的发动操作，将目标怪兽特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上或被除外，并将其特殊召唤到场上
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
