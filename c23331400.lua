--リンク・ストリーマー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，自己场上有电子界族怪兽召唤·特殊召唤时才能发动。在自己场上把1只「数据衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
function c23331400.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡已在怪兽区域存在的状态，自己场上有电子界族怪兽召唤·特殊召唤时才能发动。在自己场上把1只「数据衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23331400)
	e1:SetCondition(c23331400.tkcon)
	e1:SetTarget(c23331400.tktg)
	e1:SetOperation(c23331400.tkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断被召唤/特殊召唤的怪兽是否为表侧表示、电子界族且由我方控制，以此确认是否满足“自己场上有电子界族怪兽召唤·特殊召唤”的时点条件。
function c23331400.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 发动条件判定：本次召唤/特殊召唤成功的怪兽中至少存在1只满足cfilter的电子界族怪兽，且该组中不包含连接流式鸟自身（防止自身召唤/特召时触发）。
function c23331400.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23331400.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 发动时的合法检查（chk==0）：要求我方主要怪兽区域有空位，并且当前玩家可以特殊召唤「数据衍生物」，否则效果不能发动。
function c23331400.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否仍有可用的空格，用于后续特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认玩家能够特殊召唤「数据衍生物」（电子界族·光·1星·攻/守0），两个条件同时满足才允许发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23331401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 向系统登记本次效果涉及衍生物的生成（CATEGORY_TOKEN），供后续时点/效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本次效果涉及特殊召唤（CATEGORY_SPECIAL_SUMMON），供后续时点/效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在满足条件的情况下，在我方主要怪兽区域特殊召唤1只「数据衍生物」。
function c23331400.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查：若主要怪兽区域已没有空格，则终止处理，不特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认玩家仍可以特殊召唤「数据衍生物」，防止在发动后出现不能特招的情况。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,23331401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then
		-- 创建「数据衍生物」（卡号23331401）的衍生物令牌，归属为tp。
		local token=Duel.CreateToken(tp,23331401)
		-- 将生成的「数据衍生物」以表侧表示特殊召唤到tp的场上（通常即主要怪兽区域）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
