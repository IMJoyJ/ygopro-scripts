--カード・ブレイカー
-- 效果：
-- 这张卡不能通常召唤。把自己的魔法与陷阱卡区域存在的1张卡送去墓地的场合可以表侧攻击表示特殊召唤。
function c51047350.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：‘这张卡不能通常召唤。把自己的魔法与陷阱卡区域存在的1张卡送去墓地的场合可以表侧攻击表示特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c51047350.spcon)
	e1:SetTarget(c51047350.sptg)
	e1:SetOperation(c51047350.spop)
	c:RegisterEffect(e1)
end
-- 筛选可以作为特殊召唤代价送去墓地的卡：位于主要魔陷区（0-4号魔陷格子，排除场地区和灵摆区）且满足可作为代价送去墓地。
function c51047350.filter(c)
	return c:GetSequence()<5 and c:IsAbleToGraveAsCost()
end
-- 规则特殊召唤的条件判定：当c为nil时返回true以允许系统检索；否则要求该怪兽的控制者主要怪兽区有空格，且其魔陷区存在至少1张满足filter条件的卡。
function c51047350.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽当前控制者的主要怪兽区是否存在可用的空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查该怪兽当前控制者的魔法与陷阱卡区域是否存在至少1张满足filter条件（可作为代价送去墓地）的卡。
		Duel.IsExistingMatchingCard(c51047350.filter,c:GetControler(),LOCATION_SZONE,0,1,nil)
end
-- 特殊召唤手续的目标选择处理：获取自己魔陷区所有可作为代价的卡，提示玩家选择1张；若选择成功则将其暂存到e的LabelObject并返回true，否则返回false。
function c51047350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取该玩家自己魔法与陷阱卡区域中所有满足filter条件的卡，作为可供选择的代价卡集合。
	local g=Duel.GetMatchingGroup(c51047350.filter,tp,LOCATION_SZONE,0,nil)
	-- 发送选择提示，要求玩家选择1张要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：取出此前暂存的选择卡，将其送去墓地，完成该特殊召唤所需的代价；随后由规则处理将该卡表侧攻击表示特殊召唤。
function c51047350.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为代价选择的卡送去墓地，送墓原因记为特殊召唤。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
