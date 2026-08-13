--セフィラの輝跡
-- 效果：
-- ①：自己的灵摆区域有2张「神数」卡存在，1和7的灵摆刻度适用中的场合才能把这张卡发动。自己场上有「神数」怪兽以外的怪兽存在的场合，那些怪兽全部回到持有者卡组。
-- ②：只要这张卡在魔法与陷阱区域存在，双方不是从手卡·额外卡组中不能把怪兽特殊召唤。
-- ③：只要自己的灵摆区域有卡存在，这张卡不会成为效果的对象，自己的灵摆区域的卡被破坏的场合这张卡破坏。
function c5255013.initial_effect(c)
	-- ①：自己的灵摆区域有2张「神数」卡存在，1和7的灵摆刻度适用中的场合才能把这张卡发动。自己场上有「神数」怪兽以外的怪兽存在的场合，那些怪兽全部回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c5255013.condition)
	e1:SetOperation(c5255013.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，双方不是从手卡·额外卡组中不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c5255013.splimit)
	c:RegisterEffect(e2)
	-- 只要自己的灵摆区域有卡存在，这张卡不会成为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c5255013.tgcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 自己的灵摆区域的卡被破坏的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DESTROY)
	e4:SetCondition(c5255013.descon)
	e4:SetOperation(c5255013.desop)
	c:RegisterEffect(e4)
end
-- 发动条件判断：确认自己灵摆区域左右两侧都有「神数」卡，且两侧刻度经排序后为1和7（即1和7的灵摆刻度适用中）。
function c5255013.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域左侧（序号0）的卡。
	local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取自己灵摆区域右侧（序号1）的卡。
	local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not tc1 or not tc2 or not tc1:IsSetCard(0xc4) or not tc2:IsSetCard(0xc4) then return false end
	local scl1=tc1:GetLeftScale()
	local scl2=tc2:GetRightScale()
	if scl1>scl2 then scl1,scl2=scl2,scl1 end
	return scl1==1 and scl2==7
end
-- 筛选自己场上可返回卡组的怪兽：里侧表示的怪兽或不是「神数」字段的怪兽，且满足能够返回卡组的条件。
function c5255013.filter(c)
	return (c:IsFacedown() or not c:IsSetCard(0xc4)) and c:IsAbleToDeck()
end
-- 效果处理：将自己场上符合条件（非「神数」怪兽或里侧怪兽）的所有怪兽弹回持有者卡组并洗牌。
function c5255013.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足filter条件的怪兽，作为将要返回卡组的对象。
	local g=Duel.GetMatchingGroup(c5255013.filter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽以效果原因送回持有者卡组并洗牌（SEQ_DECKSHUFFLE表示回卡组后洗牌）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 特殊召唤限制判定：若怪兽不是从手卡或额外卡组进行特殊召唤，则禁止该特殊召唤，从而确保双方只能从手卡·额外卡组特殊召唤怪兽。
function c5255013.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsLocation(LOCATION_HAND+LOCATION_EXTRA)
end
-- 抗性条件判断：只要自己灵摆区域存在任意卡，本卡就获得“不能成为效果对象”的永久效果。
function c5255013.tgcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己灵摆区域是否有卡存在（左侧或右侧任一位置有卡即满足）。
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) or Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
-- 筛选被破坏的卡是否属于自己且位于灵摆区域，用于判断是否触发自毁。
function c5255013.desfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_PZONE)
end
-- 自毁触发条件：当自己灵摆区域存在卡片被破坏时，满足条件。
function c5255013.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5255013.desfilter,1,nil,tp)
end
-- 自毁处理：将此卡自身破坏。
function c5255013.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
