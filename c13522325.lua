--炎の精霊 イフリート
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤。
-- ①：这张卡的攻击力在自己战斗阶段内上升300。
function c13522325.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只炎属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c13522325.spcon)
	e1:SetTarget(c13522325.sptg)
	e1:SetOperation(c13522325.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力在自己战斗阶段内上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c13522325.atkcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升效果的适用条件：仅当当前回合玩家是本卡控制者，且当前阶段处于战斗阶段开始到战斗阶段结束之间（即自己的战斗阶段内）时，攻击力上升效果才适用。
function c13522325.atkcon(e)
	-- 获取当前阶段，用于判断是否处于战斗阶段范围内。
	local ph=Duel.GetCurrentPhase()
	-- 获取当前回合玩家，用于判断是否为本卡的持有/控制者自己的战斗阶段。
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 定义可选除外卡的筛选条件：该卡必须是炎属性，并且可以作为Cost被除外。
function c13522325.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件：当这张卡在手牌且场上主要怪兽区有空位，同时自己墓地存在符合筛选条件的炎属性怪兽时，才允许进行特殊召唤。
function c13522325.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前控制者场上是否有可用的主要怪兽区空格，以确定能否特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否至少存在1张满足spfilter筛选条件的炎属性怪兽（即可以作为Cost除外的炎属性怪兽）。
		and Duel.IsExistingMatchingCard(c13522325.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则的选择处理：从自己墓地的炎属性怪兽中让玩家选择1只需要除外的怪兽，若选择成功则将其保存到效果LabelObject并返回true以继续特殊召唤手续，否则返回false。
function c13522325.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter条件的炎属性怪兽的集合，供玩家选择要除外的卡。
	local g=Duel.GetMatchingGroup(c13522325.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向当前玩家显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则实际执行时的操作：取出之前选择保存的怪兽，将其从墓地除外，完成这个特殊召唤所需的除外手续。
function c13522325.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以表侧表示从墓地除外，除外原因为特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
