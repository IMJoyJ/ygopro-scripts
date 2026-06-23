--神芸獄徒 ディアクトロス
-- 效果：
-- 「无垢者 米底乌斯」＋「神艺」怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：自己场上的怪兽的种族是3种类以上，对方把魔法·陷阱·怪兽的效果在场上发动时才能发动。那个发动无效并破坏。
-- ③：融合召唤的这张卡被破坏的场合才能发动。自己的手卡·卡组·除外状态的1只「无垢者 米底乌斯」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用融合召唤限制并设置融合召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：使用卡号为97556336的1只怪兽和1个满足种族为神艺的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,97556336,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1cd),1,true,true)
	-- ①：以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽的种族是3种类以上，对方把魔法·陷阱·怪兽的效果在场上发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。自己的手卡·卡组·除外状态的1只「无垢者 米底乌斯」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 表示形式变更效果的过滤函数，判断目标怪兽是否可以改变表示形式
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 表示形式变更效果的目标选择函数，检查场上是否存在可改变表示形式的怪兽并选择目标
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 检查是否满足表示形式变更效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只可改变表示形式的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置表示形式变更效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 表示形式变更效果的处理函数，将目标怪兽改变表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽改变为表侧守备表示或表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 无效效果发动的条件函数，判断是否满足无效效果发动的条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置和发动玩家
	local loc,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_PLAYER)
	-- 获取己方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return p==1-tp and bit.band(loc,LOCATION_ONFIELD)~=0 and g:GetClassCount(Card.GetRace)>2
		-- 判断该卡未在战斗中被破坏且当前连锁可被无效
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 无效效果的目标选择函数，设置无效效果的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息，将发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		-- 设置破坏效果的操作信息，将发动时的目标卡破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的处理函数，使连锁发动无效并破坏目标卡
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效并确认目标卡是否与连锁相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 特殊召唤效果的发动条件函数，判断该卡是否为融合召唤且被破坏
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤效果的目标选择函数，检查是否有满足条件的「无垢者 米底乌斯」可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤效果的发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的「无垢者 米底乌斯」可特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED)
end
-- 特殊召唤效果的过滤函数，判断目标卡是否为「无垢者 米底乌斯」且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤「无垢者 米底乌斯」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「无垢者 米底乌斯」作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
