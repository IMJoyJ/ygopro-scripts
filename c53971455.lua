--赫聖の妖騎士
-- 效果：
-- 4星调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己·对方的卡从额外卡组离开的场合才能发动。自己场上的全部怪兽的攻击力上升500。那之后，可以把场上1张表侧表示卡的效果直到回合结束时无效。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从手卡·卡组把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
function c53971455.initial_effect(c)
	-- 设置同调召唤手续：4星调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsLevel,4),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己·对方的卡从额外卡组离开的场合才能发动。自己场上的全部怪兽的攻击力上升500。那之后，可以把场上1张表侧表示卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53971455,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_DECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c53971455.atkcon)
	e1:SetTarget(c53971455.atktg)
	e1:SetOperation(c53971455.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从手卡·卡组把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c53971455.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从手卡·卡组把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53971455,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,53971455)
	e3:SetCondition(c53971455.spcon)
	e3:SetTarget(c53971455.sptg)
	e3:SetOperation(c53971455.spop)
	c:RegisterEffect(e3)
end
-- 检查离开卡组/额外卡组的卡片中是否存在原本位置是额外卡组的卡。
function c53971455.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
-- 效果①的发动准备：检查自己场上是否存在表侧表示的怪兽。
function c53971455.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤自己场上表侧表示且不免疫该效果的怪兽。
function c53971455.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
-- 效果①的效果处理：使自己场上全部怪兽攻击力上升500，之后可以选场上1张表侧表示的卡效果无效。
function c53971455.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示且不受效果影响的怪兽。
	local g=Duel.GetMatchingGroup(c53971455.atkfilter,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()>0 then
		-- 遍历获取到的怪兽卡片组。
		for tc in aux.Next(g) do
			-- 自己场上的全部怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 获取场上所有可以被无效化效果的表侧表示卡片。
		local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 若存在可无效的卡，则由玩家选择是否发动后续的无效效果。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(53971455,2)) then  --"是否选卡把效果无效？"
			-- 中断当前效果处理，使前后的处理不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要无效效果的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local tg=sg:Select(tp,1,1,nil)
			-- 闪烁显示被选择的卡片。
			Duel.HintSelection(tg)
			local sc=tg:GetFirst()
			-- 无效化与目标卡片相关的连锁。
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			-- 可以把场上1张表侧表示卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e3)
			if sc:IsType(TYPE_TRAPMONSTER) then
				local e4=e2:Clone()
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				sc:RegisterEffect(e4)
			end
		end
	end
end
-- 效果②的准备：在这张卡被送去墓地的回合，给自身注册一个在回合结束时消失的标记。
function c53971455.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(53971455,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：检查自身是否存在被送去墓地回合的标记。
function c53971455.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(53971455)>0
end
-- 过滤手卡·卡组中攻击力和守备力数值相同、可特殊召唤的光属性魔法师族怪兽。
function c53971455.spfilter(c,e,tp)
	-- 检查卡片是否为光属性、魔法师族、攻守数值相同且可以特殊召唤。
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and aux.AtkEqualsDef(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及手卡·卡组是否存在符合条件的怪兽，并设置操作信息。
function c53971455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只符合特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c53971455.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的效果处理：从手卡·卡组选择1只攻守数值相同的光属性魔法师族怪兽特殊召唤。
function c53971455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c53971455.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
