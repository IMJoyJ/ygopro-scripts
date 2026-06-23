--白き森の魔狼シルウィア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡特殊召唤的场合才能发动。对方场上的表侧表示怪兽全部变成里侧守备表示。
-- ②：只要这张卡在怪兽区域存在，自己场上的幻想魔族·魔法师族的同调怪兽攻击力上升500，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤条件、苏生限制和三个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方场上的表侧表示怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的幻想魔族·魔法师族的同调怪兽攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ②：向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断对方场上是否存在可以变为里侧守备表示的表侧表示怪兽
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP) and c:IsCanTurnSet()
end
-- 效果处理前的判断函数，检查对方场上是否存在满足条件的怪兽并设置操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以变为里侧守备表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要改变表示形式的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数，将对方场上的满足条件的怪兽全部变为里侧守备表示
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将指定的怪兽全部变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果的过滤函数，用于判断是否为幻想魔族或魔法师族的同调怪兽
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
