--白き森の魔狼シルウィア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡特殊召唤的场合才能发动。对方场上的表侧表示怪兽全部变成里侧守备表示。
-- ②：只要这张卡在怪兽区域存在，自己场上的幻想魔族·魔法师族的同调怪兽攻击力上升500，向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的2倍数值的战斗伤害。
local s,id,o=GetID()
-- 定义卡片的初始化函数：为其添加同调召唤手续与苏生限制，并注册三个效果：①特殊召唤成功时让对方场上表侧表示怪兽全部变成里侧守备表示；②自己场上幻想魔族·魔法师族同调怪兽攻击力上升500；③给予向守备表示怪兽攻击时2倍贯穿战斗伤害。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（任意）＋调整以外的怪兽1只以上。
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
-- 过滤函数：筛选对方场上表侧表示且可以变成里侧守备表示的怪兽。
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP) and c:IsCanTurnSet()
end
-- 目标（发动）函数：效果发动时检查对方场上是否存在符合条件的怪兽；若存在，则将对方场上所有符合条件的怪兽登记为操作信息，表示将改变其表示形式。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上是否存在至少1只表侧表示且可变成里侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上所有表侧表示且可变成里侧守备表示的怪兽集合。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：将效果分类设为改变表示形式（CATEGORY_POSITION），对象为上述怪兽集合，数量为集合内卡数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数：处理时将对方场上所有表侧表示且可变成里侧守备表示的怪兽变为里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得对方场上所有表侧表示且可变成里侧守备表示的怪兽集合（用于处理时确认对象）。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将怪兽集合全部变更为里侧守备表示。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数：筛选自己场上的同调怪兽，且种族为幻想魔族或魔法师族，作为攻击力上升和贯穿伤害的适用对象。
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
