--海老須神鮮まつり
-- 效果：
-- ①：效果怪兽特殊召唤的场合，以那之内的1只为对象才能发动（同一连锁上最多1次）。在从那只怪兽的控制者来看的对方的场上把1只「神鲜衍生物」（水族·水·3星·攻/守0）守备表示特殊召唤。
-- ②：自己·对方的战斗阶段开始时才能发动1次。这张卡和场上的衍生物全部破坏，在自己场上把1只「海老须衍生物」（天使族·水·7星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成这个效果破坏的衍生物数量×700。
local s,id,o=GetID()
-- 初始化函数，注册卡片发动、①效果（特召衍生物）和②效果（破坏并特召衍生物）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个合并延迟事件，用于监听效果怪兽特殊召唤成功的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ①：效果怪兽特殊召唤的场合，以那之内的1只为对象才能发动（同一连锁上最多1次）。在从那只怪兽的控制者来看的对方的场上把1只「神鲜衍生物」（水族·水·3星·攻/守0）守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCode(custom_code)
	e2:SetCondition(s.tkcon)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动1次。这张卡和场上的衍生物全部破坏，在自己场上把1只「海老须衍生物」（天使族·水·7星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成这个效果破坏的衍生物数量×700。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏衍生物"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示的效果怪兽
function s.filter(c)
	return c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and c:IsFaceup()
end
-- ①效果的发动条件：特殊召唤成功的怪兽中存在表侧表示的效果怪兽
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
-- 过滤函数：判断特殊召唤的怪兽中，是否包含可以作为对象的表侧表示效果怪兽，且其控制者的对手场上有空位，且可以特殊召唤「神鲜衍生物」
function s.cfilter(c,g,tp)
	return g:IsContains(c) and c:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER) and c:IsFaceup()
		-- 检查该怪兽控制者的对手场上是否有可用的怪兽区域
		and Duel.GetLocationCount(1-c:GetControler(),LOCATION_MZONE)>0
		-- 检查是否能将「神鲜衍生物」以守备表示特殊召唤到该怪兽控制者的对手场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-c:GetControler())
end
-- ①效果的发动准备与对象选择，包含对已选择对象的合法性检查
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and chkc:IsAllTypes(TYPE_EFFECT+TYPE_MONSTER)
		and chkc:IsFaceup() and chkc:IsOnField()
		-- 检查作为对象的怪兽的控制者的对手场上是否有可用的怪兽区域
		and Duel.GetLocationCount(1-chkc:GetControler(),LOCATION_MZONE)>0
		-- 检查是否能将「神鲜衍生物」特殊召唤到作为对象的怪兽的控制者的对手场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-chkc:GetControler())
	end
	-- 检查场上是否存在符合条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eg,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置产生衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ①效果的实际处理：在对象怪兽控制者的对手场上特殊召唤1只「神鲜衍生物」
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)) then return end
	local sp=tc:GetControler()
	-- 检查对象怪兽控制者的对手场上是否还有空余的怪兽区域
	if Duel.GetLocationCount(1-sp,LOCATION_MZONE)<=0
		-- 检查是否无法在对象怪兽控制者的对手场上特殊召唤「神鲜衍生物」，若是则结束处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,1-sp) then return end
	-- 创建「神鲜衍生物」的卡片数据
	local token=Duel.CreateToken(tp,id+o)
	-- 将「神鲜衍生物」以守备表示特殊召唤到对象怪兽控制者的对手场上
	Duel.SpecialSummon(token,0,tp,1-sp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动准备，检查场上是否有衍生物和这张卡，以及是否能特殊召唤「海老须衍生物」
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	g:AddCard(c)
	-- 检查场上是否存在衍生物，且这些卡被破坏后自己场上是否有空余的怪兽区域
	if chk==0 then return g:GetCount()>0 and Duel.GetMZoneCount(tp,g)>0
		-- 检查是否可以特殊召唤「海老须衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER,-2,-2,7,RACE_FAIRY,ATTRIBUTE_WATER) end
	-- 设置破坏操作的信息，包含这张卡和场上所有的衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果的实际处理：破坏这张卡和场上的衍生物，并特殊召唤「海老须衍生物」，根据破坏的衍生物数量确定其攻守
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e),TYPE_TOKEN)
	if g:GetCount()==0 then return end
	g:AddCard(c)
	-- 尝试破坏这张卡和场上的衍生物，并判断是否有卡被成功破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取本次效果实际被破坏的卡片组
		local og=Duel.GetOperatedGroup()
		if not og:IsContains(c) or og:GetCount()<2
			-- 检查是否无法特殊召唤「海老须衍生物」，若是则结束处理
			or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER,-2,-2,7,RACE_FAIRY,ATTRIBUTE_WATER) then return end
		local atk=og:GetCount()-1
		-- 创建「海老须衍生物」的卡片数据
		local token=Duel.CreateToken(tp,id+o*2)
		-- 这衍生物的攻击力·守备力变成这个效果破坏的衍生物数量×700。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(atk*700)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
		-- 将「海老须衍生物」在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
