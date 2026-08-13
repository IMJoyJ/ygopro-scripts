--バーニング・ソウル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有8星以上的同调怪兽存在的场合才能发动。「燃烧之魂」以外的自己墓地1张卡加入手卡。那之后，进行1只同调怪兽的同调召唤。这张卡的发动后，直到回合结束时对方不能把场上的同调怪兽作为效果的对象。
function c10723472.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有8星以上的同调怪兽存在的场合才能发动。「燃烧之魂」以外的自己墓地1张卡加入手卡。那之后，进行1只同调怪兽的同调召唤。这张卡的发动后，直到回合结束时对方不能把场上的同调怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,10723472+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10723472.condition)
	e1:SetTarget(c10723472.target)
	e1:SetOperation(c10723472.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象为表侧表示、等级8以上且为同调怪兽。
function c10723472.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件判定：自己场上的主要怪兽区是否存在至少1只满足cfilter的怪兽。
function c10723472.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以tp方场上的主要怪兽区（包含额外怪兽区）是否存在至少1只满足cfilter的怪兽。
	return Duel.IsExistingMatchingCard(c10723472.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 墓地回手卡的过滤条件：卡名不是「燃烧之魂」且能够加入手卡。
function c10723472.thfilter(c)
	return not c:IsCode(10723472) and c:IsAbleToHand()
end
-- 发动时的合法检测：卡组存在至少1张可加入手卡的非「燃烧之魂」墓地球怪兽，且额外卡组存在至少1只可进行同调召唤的同调怪兽（满足同调素材条件）。
function c10723472.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时检测：自己墓地是否存在满足thfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c10723472.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 同时检测额外卡组是否存在可以同调召唤的同调怪兽。
		and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置操作信息：本次效果将进行回手牌处理，候选为自己墓地1张卡（处理时确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：本次效果将进行特殊召唤处理，候选为自己额外卡组1只同调怪兽（处理时确定，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从自己墓地选择1张非「燃烧之魂」且能回手卡的卡加入手卡，若成功回手则向对方确认，然后从额外卡组选择1只满足同调召唤条件的同调怪兽进行同调召唤；之后，在场上设置对方不能以场上的表侧同调怪兽为效果对象的永续效果，直到结束阶段。
function c10723472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示信息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足thfilter且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10723472.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	-- 若选择的卡不为空且成功送入持有者手卡，并且该卡现在位于手牌，则继续后续处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 获取自己额外卡组中所有当前可以进行同调召唤的同调怪兽。
		local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
		if sg:GetCount()>0 then
			-- 显示选择提示信息，提示玩家选择要特殊召唤的同调怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local pg=sg:Select(tp,1,1,nil)
			-- 以选中的同调怪兽为对象，从场上素材进行同调召唤手续（不指定调整）。
			Duel.SynchroSummon(tp,pg:GetFirst(),nil)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时对方不能把场上的同调怪兽作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c10723472.tglimit)
		-- 设置该效果的判定值为aux.tgoval，即仅对方发动的效果不能以其场上的表侧同调怪兽为对象。
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向全场注册该效果，使对方不能以场上的表侧同调怪兽为效果对象，直到结束阶段。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选目标：表侧表示且为同调怪兽的场上的怪兽。
function c10723472.tglimit(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
