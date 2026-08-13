--トラップ・イーター
-- 效果：
-- 这张卡不能通常召唤。把对方场上表侧表示存在的1张陷阱卡送去墓地的场合才能特殊召唤。
function c13821299.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把对方场上表侧表示存在的1张陷阱卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c13821299.spcon)
	e2:SetTarget(c13821299.sptg)
	e2:SetOperation(c13821299.spop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的卡：对方场上的表侧表示陷阱卡，且可以作为cost送去墓地。
function c13821299.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件判定：若c为nil则直接允许（用于规则判断），否则需要我方主要怪兽区有空位，且对方场上有符合条件的陷阱卡。
function c13821299.spcon(e,c)
	if c==nil then return true end
	-- 判断该特殊召唤怪兽的控制者（即这张卡所属玩家）场上是否存在可用的主要怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1张满足spfilter条件的卡（表侧表示陷阱卡且可作为cost送去墓地）。
		and Duel.IsExistingMatchingCard(c13821299.spfilter,c:GetControler(),0,LOCATION_ONFIELD,1,nil)
end
-- 特殊召唤的代价选择：从对方场上符合条件的陷阱卡中选择1张作为送去墓地的对象，并保存到效果中。
function c13821299.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足条件的表侧表示陷阱卡组成候选集合。
	local g=Duel.GetMatchingGroup(c13821299.spfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 向玩家显示选择提示，要求选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：取出之前选择的卡，将其送去墓地。
function c13821299.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的对方陷阱卡以特殊召唤为理由（代价）送入墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
