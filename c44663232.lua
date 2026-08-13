--異怪の妖精 エルフォビア
-- 效果：
-- 1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方的主要阶段1结束时，双方玩家不能把比给人观看的怪兽等级高的怪兽的效果发动。
function c44663232.initial_effect(c)
	-- ①：1回合1次，把手卡1只风属性怪兽给对方观看才能发动。直到下次的对方主要阶段1结束时，双方不能把比给人观看的怪兽等级高的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44663232,0))  --"效果抑制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c44663232.cost)
	e2:SetOperation(c44663232.operation)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：选择手卡中满足条件的卡——风属性且非公开状态的怪兽。
function c44663232.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPublic()
end
-- 发动代价的处理：检查是否存在可展示的风属性手卡怪兽；若有则让玩家选择1张给对方确认，记录其等级，并洗切手卡。
function c44663232.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查（chk==0）时，确认自己手卡是否存在至少1张满足风属性且非公开状态的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44663232.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送选择提示，要求选择一张要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡中选择1只符合条件（风属性且非公开状态）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c44663232.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 由于手卡中的一张被公开确认，洗切自己的手卡以隐藏手牌顺序信息。
	Duel.ShuffleHand(tp)
end
-- 效果处理：创建一个持续到下次对方主要阶段1结束的领域效果，在该效果适用期间，双方不能发动等级高于所展示怪兽的怪兽效果。
function c44663232.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的对方主要阶段1结束时，双方不能把比给人观看的怪兽等级高的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetLabel(e:GetLabel()+1)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_OPPO_TURN)
	e1:SetValue(c44663232.val)
	-- 将上述领域禁止效果注册到场上，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 禁止效果的判定函数：若试图发动的效果是怪兽效果，且该怪兽的等级高于展示怪兽的等级，则禁止发动。
function c44663232.val(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLevelAbove(e:GetLabel())
end
