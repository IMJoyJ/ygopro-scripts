--青眼の精霊龍
-- 效果：
-- 调整＋调整以外的「青眼」怪兽1只以上
-- ①：只要这张卡在怪兽区域存在，双方不能把2只以上的怪兽同时特殊召唤。
-- ②：1回合1次，墓地的卡的效果发动时才能发动。那个发动无效。
-- ③：自己·对方回合，把同调召唤的这张卡解放才能发动。从额外卡组把「青眼精灵龙」以外的1只龙族·光属性同调怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
local s,id,o=GetID()
-- 初始化函数，注册同调召唤手续、限制双方同时特召2只以上怪兽的永续效果、无效墓地效果发动的即时诱发效果，以及解放自身特召额外卡组龙族·光属性同调怪兽的即时诱发效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的「青眼」怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0xdd),1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，双方不能把2只以上的怪兽同时特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，墓地的卡的效果发动时才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，把同调召唤的这张卡解放才能发动。从额外卡组把「青眼精灵龙」以外的1只龙族·光属性同调怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 设置效果②（无效发动）的发动条件：墓地的卡的效果发动时，且该发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查效果发动地点是否在墓地，且该连锁的发动是否可以被无效。
	return re:GetActivateLocation()==LOCATION_GRAVE and Duel.IsChainNegatable(ev)
end
-- 设置效果②（无效发动）的靶向与操作信息：在发动时，设置操作信息为“使该连锁的发动无效”。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使该连锁的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 设置效果②（无效发动）的效果处理：使该连锁的发动无效。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使指定连锁的发动无效。
	Duel.NegateActivation(ev)
end
-- 设置效果③（特殊召唤）的发动条件：自身必须是同调召唤上场的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果③（特殊召唤）的发动代价：解放自身。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤额外卡组中除「青眼精灵龙」以外的龙族·光属性同调怪兽，且能以守备表示特殊召唤，并且额外怪兽区域有可用位置。
function s.spfilter(c,e,tp,mc)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO)
		and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查在解放自身后，额外卡组怪兽特殊召唤到场上是否有可用的空格。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果③（特殊召唤）的靶向与操作信息：检查额外卡组是否存在满足条件的怪兽，并设置操作信息为“从额外卡组特殊召唤1只怪兽”。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查额外卡组是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 设置效果③（特殊召唤）的效果处理：从额外卡组选择1只满足条件的怪兽守备表示特殊召唤，并注册一个在回合结束阶段将其破坏的延迟效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的怪兽以表侧守备表示特殊召唤。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		-- 注册全局环境效果，用于在结束阶段执行破坏处理。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 设置结束阶段破坏效果的触发条件：检查目标怪兽是否仍带有对应的标记（即是否为该效果特殊召唤的怪兽）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(id)==e:GetLabel()
end
-- 设置结束阶段破坏效果的处理：展示卡片动画并破坏该怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡片（青眼精灵龙）的卡片动画。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
