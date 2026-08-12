--リンク・ストリーマー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，自己场上有电子界族怪兽召唤·特殊召唤时才能发动。在自己场上把1只「数据衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
function c23331400.initial_effect(c)
	-- ①：这张卡已在怪兽区域存在的状态，自己场上有电子界族怪兽召唤·特殊召唤时才能发动。在自己场上把1只「数据衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
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
-- 检查目标怪兽是否为表侧表示、电子界族、且为当前控制者
function c23331400.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsControler(tp)
end
-- 判断发动时是否有满足条件的电子界族怪兽被召唤或特殊召唤，且不包含自身
function c23331400.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23331400.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 判断是否满足发动条件：场上存在空位且可以特殊召唤数据衍生物
function c23331400.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23331401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：将要特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤1只衍生物（重复设置）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行效果处理：若满足条件则特殊召唤数据衍生物
function c23331400.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤数据衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,23331401,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then
		-- 创建1只数据衍生物
		local token=Duel.CreateToken(tp,23331401)
		-- 将创建的衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
