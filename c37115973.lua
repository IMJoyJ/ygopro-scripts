--ナンバーズハンター
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。场上的「No.」超量怪兽全部回到持有者的额外卡组。
-- ②：只要这张卡在怪兽区域存在，双方不能把「No.」超量怪兽特殊召唤。此外，这张卡不会被和超量怪兽的战斗破坏，不受超量怪兽的效果影响。
function c37115973.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合发动。场上的「No.」超量怪兽全部回到持有者的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37115973,0))  --"回到额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c37115973.target)
	e1:SetOperation(c37115973.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，双方不能把「No.」超量怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c37115973.splimit)
	c:RegisterEffect(e4)
	-- 此外，这张卡不会被和超量怪兽的战斗破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(c37115973.indval)
	c:RegisterEffect(e5)
	-- 不受超量怪兽的效果影响。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(c37115973.efilter)
	c:RegisterEffect(e6)
end
-- 过滤条件：选择持有「No.」字段的超量怪兽，且该卡可以被送回额外卡组。
function c37115973.filter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- 效果发动时的合法性检查始终通过；收集场上所有符合条件的「No.」超量怪兽，并设置将那些卡送回额外卡组的操作信息。
function c37115973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取全场（双方怪兽区域）中所有符合filter条件的「No.」超量怪兽。
	local g=Duel.GetMatchingGroup(c37115973.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果处理涉及将g中的卡返回额外卡组，数量为g的数量，用于连锁/效果发动时对“回额外卡组”类动作的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,g:GetCount(),0,0)
end
-- 效果处理时再次获取场上符合条件的「No.」超量怪兽，若存在则全部送回持有者的额外卡组。
function c37115973.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前场上符合条件的「No.」超量怪兽，避免使用发动时已过时的集合。
	local g=Duel.GetMatchingGroup(c37115973.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 以效果原因将g中的全部「No.」超量怪兽返回持有者的额外卡组（额外卡组顶端）。
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 特殊召唤限制的判断条件：被特殊召唤的怪兽持有「No.」字段且为超量怪兽时，禁止该特殊召唤。
function c37115973.splimit(e,c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 战斗破坏抗性的判定条件：与此卡战斗的对方怪兽是超量怪兽时，此卡不会被那次战斗破坏。
function c37115973.indval(e,c)
	return c:IsType(TYPE_XYZ)
end
-- 效果免疫的判定条件：来源效果的类型是超量怪兽（即超量怪兽发动的效果）时，此卡不受该效果影响。
function c37115973.efilter(e,te)
	return te:IsActiveType(TYPE_XYZ)
end
