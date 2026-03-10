--カード・ブレイカー
-- 效果：
-- 这张卡不能通常召唤。把自己的魔法与陷阱卡区域存在的1张卡送去墓地的场合可以表侧攻击表示特殊召唤。
function c51047350.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建一个特殊召唤程序效果，用于满足特定条件时将卡片特殊召唤到场上
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
-- 过滤函数，用于筛选魔法与陷阱区域中可被送入墓地的卡
function c51047350.filter(c)
	return c:GetSequence()<5 and c:IsAbleToGraveAsCost()
end
-- 判断特殊召唤条件是否满足，包括是否有足够的怪兽区域和是否存在可送墓的魔法/陷阱卡
function c51047350.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家场上是否有足够的怪兽区域可用于特殊召唤
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 确认玩家的魔法与陷阱区域中是否存在至少一张可作为费用送入墓地的卡
		Duel.IsExistingMatchingCard(c51047350.filter,c:GetControler(),LOCATION_SZONE,0,1,nil)
end
-- 设置特殊召唤的目标选择函数，用于从魔法与陷阱区域选择一张卡送入墓地
function c51047350.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家魔法与陷阱区域中所有满足条件的卡组
	local g=Duel.GetMatchingGroup(c51047350.filter,tp,LOCATION_SZONE,0,nil)
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤的操作函数，将选定的卡送去墓地并完成特殊召唤手续
function c51047350.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡送去墓地，并以特殊召唤原因为由进行处理
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
