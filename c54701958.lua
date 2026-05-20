--月光舞獅子神姫
-- 效果：
-- 「月光舞狮子姬」＋「月光」怪兽×3
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不受「月光」卡以外的卡的效果影响。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：自己·对方回合1次，从额外卡组把1只「月光」怪兽送去墓地才能发动。对方场上的特殊召唤的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、特殊召唤限制、不受「月光」以外卡片效果影响、同一次战斗阶段作2次攻击以及破坏对方场上特殊召唤怪兽的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤素材为「月光舞狮子姬」加上3只「月光」怪兽。
	aux.AddFusionProcCodeFun(c,24550676,aux.FilterBoolFunction(Card.IsFusionSetCard,0xdf),3,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过融合召唤的方式特殊召唤。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡只要在怪兽区域存在，不受「月光」卡以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合1次，从额外卡组把1只「月光」怪兽送去墓地才能发动。对方场上的特殊召唤的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤不受影响的效果，判断效果来源卡片是否不属于「月光」系列。
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0xdf)
end
-- 过滤作为发动代价的卡片，需为额外卡组的「月光」怪兽且能送去墓地。
function s.costfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的发动代价处理函数，从额外卡组将1只「月光」怪兽送去墓地。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足条件的「月光」怪兽作为代价送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1只满足条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤要破坏的怪兽，需为特殊召唤的怪兽。
function s.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 破坏效果的发动检测与目标确认函数。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁信息，表示该效果的处理为破坏对方场上所有特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理函数。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上所有特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 破坏获取到的所有特殊召唤的怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
