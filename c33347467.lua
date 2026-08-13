--霊魂の護送船
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的1只光属性怪兽从游戏中除外的场合可以特殊召唤。
function c33347467.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己墓地存在的1只光属性怪兽从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33347467.spcon)
	e1:SetTarget(c33347467.sptg)
	e1:SetOperation(c33347467.spop)
	c:RegisterEffect(e1)
end
-- 过滤墓地中存在的光属性怪兽，且该怪兽可以作为除外的代价。
function c33347467.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则效果的条件：自己场上有可用的怪兽区域，且墓地存在至少1只满足条件的光属性怪兽。
function c33347467.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只光属性且可以除外的怪兽。
		and Duel.IsExistingMatchingCard(c33347467.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 发动特殊召唤规则效果时，从符合条件的墓地光属性怪兽中选择1只作为除外的对象；选择成功才进行特殊召唤，并将选中卡存入效果标签。
function c33347467.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中所有满足条件（光属性且可除外）的怪兽集合。
	local g=Duel.GetMatchingGroup(c33347467.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果处理：将选择的光属性怪兽除外，以完成特殊召唤手续。
function c33347467.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的那只光属性怪兽从墓地除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
