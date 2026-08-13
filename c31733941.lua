--レッドアイズ・トゥーン・ドラゴン
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：1回合1次，自己主要阶段才能发动。从手卡把「真红眼卡通龙」以外的1只卡通怪兽无视召唤条件特殊召唤。
function c31733941.initial_effect(c)
	-- 将「卡通世界」（15259703）登记为本卡记载的关联卡名，用于支持与卡通世界相关的规则判定。
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
-- 当这张卡召唤·反转召唤·特殊召唤成功时，为其赋予一个「不能攻击」的效果，该效果持续到回合结束。
function c31733941.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：判断一张卡是否为表侧表示且卡名为「卡通世界」（15259703）。
function c31733941.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤函数：判断一张卡是否为表侧表示且为卡通怪兽（TYPE_TOON）。
function c31733941.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击的条件：自己场上有表侧表示的「卡通世界」，且对方场上没有表侧表示的卡通怪兽；满足时这张卡可以直接攻击。
function c31733941.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上（怪兽区·魔法陷阱区）是否存在至少1张表侧表示的「卡通世界」。
	return Duel.IsExistingMatchingCard(c31733941.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并检查对方场上（主要怪兽区）不存在表侧表示的卡通怪兽。
		and not Duel.IsExistingMatchingCard(c31733941.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤候选过滤：手牌中的卡通怪兽、不是「真红眼卡通龙」自身、且可以无视召唤条件进行特殊召唤。
function c31733941.spfilter(c,e,tp)
	return c:IsType(TYPE_TOON) and not c:IsCode(31733941) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③的发动合法性判定：自己主要怪兽区有空位，且手牌中存在符合条件的卡通怪兽。
function c31733941.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区还有可用区域（大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认手牌中存在满足特殊召唤条件的卡通怪兽。
		and Duel.IsExistingMatchingCard(c31733941.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向连锁信息登记本次效果将进行1张手牌的特殊召唤（不指定具体卡，处理时选择），以便其他卡牌连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③的效果处理：若主要怪兽区无空位则中止；否则从手牌选择1只符合条件的卡通怪兽，无视召唤条件以表侧表示特殊召唤。
function c31733941.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否有空位，没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 为玩家显示选择提示‘请选择要特殊召唤的卡’，用于接下来的手牌选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1张满足spfilter条件的卡通怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c31733941.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡通怪兽以表侧表示特殊召唤到自己场上；nocheck=true（无视召唤条件），nolimit=false（仍需检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
