--創世の神 デウテロノミオン
-- 效果：
-- 这张卡不能通常召唤。「创世之神 狄特罗诺米安」1回合1次在把原本攻击力和原本守备力是2500的自己场上1只表侧表示怪兽除外的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「再世」魔法·陷阱卡在自己场上盖放。
-- ②：这张卡的攻击力在战斗阶段内上升2500。
-- ③：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
local s,id,o=GetID()
-- 初始化卡片效果，启用复活限制并注册多个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「创世之神 狄特罗诺米安」1回合1次在把原本攻击力和原本守备力是2500的自己场上1只表侧表示怪兽除外的场合才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤的场合才能发动。从卡组把1张「再世」魔法·陷阱卡在自己场上盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	-- 这张卡的攻击力在战斗阶段内上升2500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetValue(2500)
	c:RegisterEffect(e4)
	-- 这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的怪兽：表侧表示、原本攻击力和守备力均为2500、可以作为除外费用
function s.spfilter(c,tp)
	return c:IsFaceup() and c:GetBaseAttack()==2500 and c:GetBaseDefense()==2500 and c:IsAbleToRemoveAsCost()
		-- 满足条件的怪兽还必须可以被除外且场上存在可用怪兽区
		and c:IsAbleToRemove(tp,POS_FACEUP,REASON_SPSUMMON) and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否有满足条件的怪兽可以除外用于特殊召唤
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 选择并标记要除外的怪兽，用于后续特殊召唤操作
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足特殊召唤条件的怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤时的除外操作
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤满足条件的「再世」魔法或陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 判断是否可以发动盖放效果
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「再世」魔法或陷阱卡
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放效果，选择并盖放一张「再世」魔法或陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张满足条件的「再世」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 判断是否处于战斗阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为战斗阶段
	return Duel.IsBattlePhase()
end
