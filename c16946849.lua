--人造天使
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，每次反击陷阱卡发动，在自己场上把1只「人造天使衍生物」（天使族·光·1星·攻/守300）特殊召唤。
function c16946849.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，每次反击陷阱卡发动，在自己场上把1只「人造天使衍生物」（天使族·光·1星·攻/守300）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(c16946849.tokencon)
	e2:SetOperation(c16946849.tokenop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤衍生物的条件
function c16946849.tokencon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保发动的是魔法卡且为反击陷阱卡，且自己场上存在空位
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确保自己可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16946850,0,TYPES_TOKEN_MONSTER,300,300,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
end
-- 执行特殊召唤衍生物的操作
function c16946849.tokenop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建指定编号的衍生物token
	local token=Duel.CreateToken(tp,16946850)
	-- 将创建好的衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
