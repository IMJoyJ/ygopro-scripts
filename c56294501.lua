--ジャンクスリープ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方对怪兽的召唤·特殊召唤成功的场合才能发动。自己场上的里侧守备表示怪兽全部变成表侧攻击表示。
-- ②：自己·对方的结束阶段才能发动。自己场上的怪兽全部变成里侧守备表示。
function c56294501.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方对怪兽的召唤·特殊召唤成功的场合才能发动。自己场上的里侧守备表示怪兽全部变成表侧攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56294501,0))  --"变成表侧表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,56294501)
	e2:SetCondition(c56294501.chcon)
	e2:SetTarget(c56294501.chtg)
	e2:SetOperation(c56294501.chop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己·对方的结束阶段才能发动。自己场上的怪兽全部变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56294501,1))  --"变成里侧表示"
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,56294502)
	e4:SetTarget(c56294501.chtg2)
	e4:SetOperation(c56294501.chop2)
	c:RegisterEffect(e4)
end
-- 过滤条件：判断怪兽是否由对方召唤·特殊召唤
function c56294501.filter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 发动条件：对方对怪兽的召唤·特殊召唤成功的场合
function c56294501.chcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56294501.filter,1,nil,tp)
end
-- 过滤条件：自己场上里侧表示且可以改变表示形式的怪兽
function c56294501.chfilter(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end
-- ①号效果的发动准备：检查并获取自己场上里侧守备表示的怪兽，并设置改变表示形式的操作信息
function c56294501.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否存在至少1只里侧表示且可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56294501.chfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有里侧表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c56294501.chfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：改变表示形式，对象为自己场上所有符合条件的里侧怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ①号效果的执行：将自己场上的里侧守备表示怪兽全部变成表侧攻击表示
function c56294501.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有里侧表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c56294501.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成表侧攻击表示
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
end
-- ②号效果的发动准备：检查并获取自己场上可以变成里侧表示的怪兽，并设置改变表示形式的操作信息
function c56294501.chtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否存在至少1只可以变成里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：改变表示形式，对象为自己场上所有符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②号效果的执行：将自己场上的怪兽全部变成里侧守备表示
function c56294501.chop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
