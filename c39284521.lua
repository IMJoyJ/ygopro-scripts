--マシンナーズ・カノン
-- 效果：
-- 这张卡不能通常召唤。把这张卡以外的手卡的机械族怪兽任意数量送去墓地的场合可以特殊召唤。
-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽数量×800。
function c39284521.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个字段效果，用于规定此卡的特殊召唤条件
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
-- 过滤函数，用于判断手牌中是否包含机械族且可作为墓地代价的怪兽
function c39284521.spfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤的条件函数，检查是否有足够的怪兽区以及手牌中是否存在满足条件的机械族怪兽
function c39284521.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查当前玩家手牌中是否存在至少一张满足条件的机械族怪兽
		and Duel.IsExistingMatchingCard(c39284521.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 选择怪兽送去墓地的处理函数，允许玩家从手牌中选择任意数量的机械族怪兽送去墓地
function c39284521.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的机械族怪兽组
	local g=Duel.GetMatchingGroup(c39284521.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:CancelableSelect(tp,1,g:GetCount(),nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤时的处理函数，将选择的怪兽送去墓地并为自身增加攻击力
function c39284521.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽组以特殊召唤的理由送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- ①：这张卡的攻击力上升因为这张卡特殊召唤而送去墓地的怪兽数量×800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*800)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	g:DeleteGroup()
end
