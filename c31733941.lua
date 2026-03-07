--レッドアイズ・トゥーン・ドラゴン
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：1回合1次，自己主要阶段才能发动。从手卡把「真红眼卡通龙」以外的1只卡通怪兽无视召唤条件特殊召唤。
function c31733941.initial_effect(c)
	-- 记录此卡与「卡通世界」的关联
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c31733941.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c31733941.dircon)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己主要阶段才能发动。从手卡把「真红眼卡通龙」以外的1只卡通怪兽无视召唤条件特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c31733941.sptg)
	e5:SetOperation(c31733941.spop)
	c:RegisterEffect(e5)
end
-- 效果作用：使此卡在召唤·反转召唤·特殊召唤的回合不能攻击
function c31733941.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使此卡在召唤·反转召唤·特殊召唤的回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在「卡通世界」
function c31733941.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数：检查对方场上是否存在卡通怪兽
function c31733941.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 效果作用：判断是否满足直接攻击条件
function c31733941.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断自己场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c31733941.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c31733941.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤函数：检查手牌中是否含有非此卡的卡通怪兽
function c31733941.spfilter(c,e,tp)
	return c:IsType(TYPE_TOON) and not c:IsCode(31733941) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果作用：判断是否满足特殊召唤条件
function c31733941.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在符合条件的卡通怪兽
		and Duel.IsExistingMatchingCard(c31733941.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只卡通怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：执行特殊召唤操作
function c31733941.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手牌中符合条件的1只卡通怪兽
	local g=Duel.SelectMatchingCard(tp,c31733941.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡通怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
