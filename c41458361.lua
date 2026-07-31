--魔救の輝跡
local s,id,o=GetID()
-- 为卡片添加连接召唤手续并注册三个效果
function s.initial_effect(c)
	-- 设置连接召唤需要至少2个且至多2个满足类型为效果怪兽的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- 这张卡连接召唤成功的场合，以自己场上1只表侧表示怪兽为对象才能发动。从卡组特殊召唤1只衍生物（战士族·光·攻击力0·守备力0）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon1)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tkcon2)
	c:RegisterEffect(e2)
	-- 对方把怪兽的效果发动时才能发动。那只怪兽回到卡组顶部
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 连接素材中必须包含至少1只同调怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SYNCHRO)
end
-- 效果适用条件：此卡为连接召唤方式特殊召唤成功
function s.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 用于判断目标是否在连接组内
function s.cfilter(c,lg)
	return lg:IsContains(c)
end
-- 效果适用条件：有连接怪兽被特殊召唤，且该怪兽在当前连锁中
function s.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.cfilter,1,nil,lg)
end
-- 筛选满足条件的怪兽作为特殊召唤对象
function s.tfilter(c,tp)
	return c:IsFaceupEx() and c:IsLevelAbove(1)
		-- 检查玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT)
end
-- 设置选择目标时的过滤条件和判断是否能发动效果
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.tfilter(chkc,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 优先从场上选择满足条件的目标怪兽
	aux.SelectTargetFromFieldFirst(tp,s.tfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理特殊召唤衍生物的效果
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于连锁中且处于表侧表示状态
	if tc:IsRelateToChain() and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,tc:GetLevel(),RACE_ROCK,ATTRIBUTE_LIGHT) then
		-- 创建一张指定编号的衍生物
		local token=Duel.CreateToken(tp,id+o)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 设置衍生物等级与原怪兽相同
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断发动效果的怪兽是否在场且与效果相关联
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER) and c~=rc
end
-- 设置选择目标时的过滤条件和判断是否能发动效果
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToDeck() end
	-- 设置操作信息为将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end
-- 处理将怪兽送回卡组的效果
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) and rc:IsLocation(LOCATION_MZONE) then
		-- 将指定怪兽送回卡组顶部
		Duel.SendtoDeck(rc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
