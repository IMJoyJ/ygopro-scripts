--人造天使
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次反击陷阱卡发动，在自己场上把1只「人造天使衍生物」（天使族·光·1星·攻/守300）特殊召唤。
function c16946849.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次反击陷阱卡发动，在自己场上把1只「人造天使衍生物」（天使族·光·1星·攻/守300）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(c16946849.tokencon)
	e2:SetOperation(c16946849.tokenop)
	c:RegisterEffect(e2)
end
-- 判定是否满足触发条件：本次连锁中发动的效果是反击陷阱卡，且自己场上可特殊召唤，并且能够生成「人造天使衍生物」。
function c16946849.tokencon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本次连锁处理结束时的来源效果是否为反击陷阱卡的发动（re具有EFFECT_TYPE_ACTIVATE且为反击陷阱类型），并确认自己主要怪兽区有空位。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认自己是否可以特殊召唤「人造天使衍生物」（等级1、天使族、光属性、攻/守300）到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
end
-- 效果处理函数：在满足条件时生成1只「人造天使衍生物」并特殊召唤到自己场上，实现效果①的衍生物特殊召唤。
function c16946849.tokenop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建1只卡号16946850的「人造天使衍生物」（天使族·光·1星·攻/守300），作为要特殊召唤的衍生物。
	local token=Duel.CreateToken(tp,16946850)
	-- 将该衍生物以表侧表示特殊召唤到当前玩家（tp）的场上，通常为主要怪兽区。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
