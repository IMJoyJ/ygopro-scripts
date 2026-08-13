--黄泉ガエル
-- 效果：
-- ①：这张卡在墓地存在，自己场上没有「黄泉青蛙」存在的场合，自己准备阶段才能发动。这张卡特殊召唤。这个效果在自己场上没有魔法·陷阱卡存在的场合才能发动和处理。
function c12538374.initial_effect(c)
	-- ①：这张卡在墓地存在，自己场上没有「黄泉青蛙」存在的场合，自己准备阶段才能发动。这张卡特殊召唤。这个效果在自己场上没有魔法·陷阱卡存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12538374,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c12538374.condition)
	e1:SetTarget(c12538374.target)
	e1:SetOperation(c12538374.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于检测自己场上是否存在魔法·陷阱卡或表侧表示的「黄泉青蛙」，作为发动条件判断的依据。
function c12538374.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) or (c:IsCode(12538374) and c:IsFaceup())
end
-- 发动条件函数：仅在当前为回合玩家的准备阶段，且自己场上不存在魔法·陷阱卡或表侧表示的「黄泉青蛙」时，效果才满足发动条件。
function c12538374.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：当前必须是自己的准备阶段，并且自己场上不存在魔法·陷阱卡或表侧表示的「黄泉青蛙」。
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c12538374.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果发动时的目标合法性判定：检查自己主要怪兽区是否有空位，且墓地的这张卡是否能够被特殊召唤，以此决定能否发动。
function c12538374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次效果将特殊召唤这张卡的操作信息登记到连锁中，供系统及后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：用于检测自己场上是否存在魔法·陷阱卡。
function c12538374.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理函数：在效果处理时，若这张卡仍与效果关联，且自己场上没有魔法·陷阱卡，则特殊召唤这张卡。
function c12538374.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时确认：这张卡没有离场且仍与效果关联，同时自己场上没有魔法·陷阱卡。
	if e:GetHandler():IsRelateToEffect(e) and not Duel.IsExistingMatchingCard(c12538374.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 将这张卡表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
