--マシンナーズ・カノン
-- 效果：
-- 这张卡不能通常召唤。把这张卡以外的手卡的机械族怪兽任意数量送去墓地的场合可以特殊召唤。
-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽数量×800。
function c39284521.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把这张卡以外的手卡的机械族怪兽任意数量送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c39284521.spcon)
	e1:SetTarget(c39284521.sptg)
	e1:SetOperation(c39284521.spop)
	c:RegisterEffect(e1)
end
-- 筛选条件：手牌中满足机械族且可以作为代价送去墓地的怪兽（不包括自身）。
function c39284521.spfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件：自己场上有可用的主要怪兽区，且手牌中除自身外存在至少1只满足上述筛选条件的机械族怪兽。
function c39284521.spcon(e,c)
	if c==nil then return true end
	-- 检查自己主要怪兽区是否有空格子可供特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张除自身以外满足机械族且可作为代价送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(c39284521.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤时选择手牌中任意数量的机械族怪兽（1张到全部）作为代价，若选择成功则保存这些卡并允许召唤，否则取消召唤。
function c39284521.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中除自身以外所有满足机械族且可作为代价送去墓地的怪兽，供玩家选择。
	local g=Duel.GetMatchingGroup(c39284521.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,1,g:GetCount(),nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤处理：将选中的机械族怪兽送去墓地，并给这张卡附加攻击力上升效果，上升数值为送去墓地的怪兽数量×800。
function c39284521.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的机械族怪兽作为特殊召唤代价送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*800)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
