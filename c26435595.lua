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
	-- 为这张卡注册融合召唤手续：以2只满足辅过滤条件（灵摆怪兽）的怪兽作为融合素材，可通过融合召唤方式出场。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_PENDULUM),2,true)
	-- 为这张卡添加灵摆怪兽属性（可进行灵摆召唤），但不注册灵摆卡“卡的发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	-- 对应灵摆效果原文：“这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域没有卡存在的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽在自己的灵摆区域放置。”此处通过SetCountLimit限制同名卡灵摆效果1回合1次，并定义了起动效果的发动条件与操作。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26435595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,26435595)
	e1:SetTarget(c26435595.pctg)
	e1:SetOperation(c26435595.pcop)
	c:RegisterEffect(e1)
	-- 对应怪兽效果原文：“①：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。”此处注册了诱发选发效果，在怪兽区域的此卡被破坏时发动。
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
-- 定义灵摆效果可选择的卡的条件：必须是表侧表示的灵摆怪兽、不是禁止卡，且放置到灵摆区域后不会因同名卡在场上的唯一性限制而无法放置。
function c26435595.pcfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 灵摆效果的发动条件判定：自己灵摆区域存在可用空格，并且自己的额外卡组存在满足pcfilter条件的表侧灵摆怪兽。
function c26435595.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的两个位置中至少有一个空格可用来放置额外卡组的灵摆怪兽。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查自己的额外卡组是否存在至少1张满足pcfilter条件的卡。
		and Duel.IsExistingMatchingCard(c26435595.pcfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
end
-- 灵摆效果的处理：从自己的额外卡组挑选1只符合条件的表侧灵摆怪兽，放置到自己的灵摆区域。
function c26435595.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己灵摆区域仍有空格，若两个位置都不可用则直接终止处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 向玩家显示“请选择要放置到场上的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己的额外卡组中选择1张满足pcfilter条件的表侧灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c26435595.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选择的那张卡以表侧表示移动到自己的灵摆区域，并立即适用其效果。
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 怪兽效果的发动条件：这张卡此前在怪兽区域，且以表侧表示被破坏，即满足原文“怪兽区域的这张卡被破坏的场合”。
function c26435595.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果的发动目标判定：检查自己灵摆区域是否有空格，用于放置被破坏的这张卡。
function c26435595.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的两个位置中至少有一个空格可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果的处理：若这张卡仍与当前效果关联，则将其移动到自己的灵摆区域。
function c26435595.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域，并立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
