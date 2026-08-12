--煉獄の決界
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的「狱火机」怪兽的攻击力上升自己的除外状态的「狱火机」怪兽数量×100。
-- ②：自己场上的怪兽不存在的场合或者只有恶魔族怪兽的场合，可以从以下效果选择1个发动。
-- ●自己的除外状态的1只「狱火机」怪兽加入手卡。
-- ●从手卡把1只「狱火机」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动、攻击力上升、除外怪兽加入手卡以及手卡怪兽特殊召唤的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「狱火机」怪兽的攻击力上升自己的除外状态的「狱火机」怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ●自己的除外状态的1只「狱火机」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外状态的怪兽加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ●从手卡把1只「狱火机」怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"从手卡把怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤出自己场上表侧表示的「狱火机」怪兽作为攻击力上升效果的影响对象
function s.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xbb)
end
-- 过滤出除外状态的表侧表示「狱火机」怪兽
function s.ckfilter(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 计算攻击力上升的数值，为除外状态的「狱火机」怪兽数量×100
function s.atkval(e,c)
	-- 获取自己除外状态的「狱火机」怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.ckfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)
	return ct*100
end
-- 过滤出里侧表示怪兽或者非恶魔族的怪兽，用于判断场上是否存在不满足条件的怪兽
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_FIEND)
end
-- 检查效果②的发动条件：自己场上没有怪兽，或者只有恶魔族怪兽
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量是否为0，或者场上不存在里侧表示怪兽且不存在非恶魔族怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤出除外状态的表侧表示且可以加入手卡的「狱火机」怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②选择「加入手卡」时的发动准备，检查是否存在可回收的怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己除外状态是否存在至少1只可以加入手卡的「狱火机」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向对方玩家提示当前选择发动的是「除外状态的怪兽加入手卡」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表明此效果的处理是将除外区的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果②选择「加入手卡」时的效果处理，将选中的除外状态「狱火机」怪兽加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己的除外状态中选择1只满足条件的「狱火机」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤出可以无视召唤条件特殊召唤的手卡中的「狱火机」怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xbb) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②选择「特殊召唤」时的发动准备，检查怪兽区域空位及手卡中是否存在可特召的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在可以特殊召唤的「狱火机」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示当前选择发动的是「从手卡把怪兽特殊召唤」效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表明此效果的处理是从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②选择「特殊召唤」时的效果处理，将手卡中的1只「狱火机」怪兽无视召唤条件特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足条件的「狱火机」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
