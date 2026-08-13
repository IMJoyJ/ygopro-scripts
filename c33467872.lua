--深海のコレペティ
-- 效果：
-- 「深海歌后」＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方回合1次，从手卡丢弃1只4星以下的水属性怪兽才能发动。这张卡的攻击力直到回合结束时上升800。
-- ②：同调召唤的这张卡被送去墓地的场合，以「深海艺术指导」以外的自己墓地1只5星以上的水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，自己不是水属性怪兽不能特殊召唤。
function c33467872.initial_effect(c)
	-- 将密码78868119（「深海歌后」）登记为本卡的素材卡名，用于同调素材的识别与效果联动。
	aux.AddMaterialCodeList(c,78868119)
	-- 设置同调召唤手续：调整必须为「深海歌后」，调整以外怪兽最少1只，满足「深海歌后」＋调整以外的怪兽1只以上的召唤条件。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,78868119),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，从手卡丢弃1只4星以下的水属性怪兽才能发动。这张卡的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33467872,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	-- 设置①效果只能在伤害步骤且伤害计算前满足条件时发动（配合EFFECT_FLAG_DAMAGE_STEP，使该二速效果在伤害步骤内也能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c33467872.atkcost)
	e1:SetOperation(c33467872.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：同调召唤的这张卡被送去墓地的场合，以「深海艺术指导」以外的自己墓地1只5星以上的水属性怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，自己不是水属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33467872,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,33467872)
	e2:SetCondition(c33467872.spcon)
	e2:SetTarget(c33467872.sptg)
	e2:SetOperation(c33467872.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果丢弃手卡的筛选条件：手牌中存在水属性、4星以下且可以被丢弃的怪兽卡。
function c33467872.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4) and c:IsDiscardable()
end
-- 定义①效果的发动代价：从手牌丢弃1只满足costfilter的水属性4星以下怪兽。
function c33467872.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己手牌存在至少1张可丢弃的水属性4星以下怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33467872.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：玩家从手牌选择并丢弃1张水属性4星以下怪兽，丢弃理由为发动cost。
	Duel.DiscardHand(tp,c33467872.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- ①效果处理：若本卡仍表侧表示且与效果关联，则让这张卡的攻击力直到回合结束时上升800。
function c33467872.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 定义②效果的发动条件：本卡被同调召唤后，从场上被送去墓地（此前所在位置是怪兽区，且召唤方式为同调召唤）。
function c33467872.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义②效果可选对象的筛选条件：自己墓地的水属性、等级5以上、卡名不是「深海艺术指导」，且可以表侧守备表示特殊召唤的怪兽。
function c33467872.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(5) and not c:IsCode(33467872)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义②效果发动时的目标选择：选择自己墓地1只满足spfilter的水属性5星以上且非本卡的怪兽作为对象，同时确认自己场上存在可用的怪兽区域。
function c33467872.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33467872.spfilter(chkc,e,tp) end
	-- 效果发动合法性检查：自己场上有可以特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动合法性检查：自己墓地存在可作为对象选择的满足条件的怪兽。
		and Duel.IsExistingTarget(c33467872.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的提示消息，告知玩家需要选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c33467872.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁处理中会进行1只怪兽的特殊召唤，便于其他卡片进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽特殊召唤，并给自己附加“这个回合不能特殊召唤非水属性怪兽”的限制。
function c33467872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个回合，自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c33467872.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤非水属性怪兽”的限制效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定函数：当特殊召唤的怪兽不是水属性时，禁止该特殊召唤。
function c33467872.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
