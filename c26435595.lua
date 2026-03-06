--聖菓使クーベル
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- 灵摆怪兽×2
-- ①：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c26435595.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足灵摆类型条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),2,true)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26435595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,26435595)
	e1:SetTarget(c26435595.pctg)
	e1:SetOperation(c26435595.pcop)
	c:RegisterEffect(e1)
	-- ①：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26435595,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c26435595.pencon)
	e2:SetTarget(c26435595.pentg)
	e2:SetOperation(c26435595.penop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽：正面表示、灵摆类型、未被禁止、在场上唯一
function c26435595.pcfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 判断灵摆效果是否可以发动：检查灵摆区域是否有空位且额外卡组是否存在满足条件的灵摆怪兽
function c26435595.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查额外卡组是否存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c26435595.pcfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
-- 灵摆效果的处理函数：检查灵摆区域是否有空位，提示选择灵摆怪兽并将其放置到灵摆区域
function c26435595.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否有空位，若无则返回
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从额外卡组选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c26435595.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽放置到灵摆区域
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断灵摆效果是否可以发动：检查卡片是否从怪兽区域被破坏且正面表示
function c26435595.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 判断灵摆效果是否可以发动：检查灵摆区域是否有空位
function c26435595.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 灵摆效果的处理函数：将自身放置到灵摆区域
function c26435595.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身放置到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
