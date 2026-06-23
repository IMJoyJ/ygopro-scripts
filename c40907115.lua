--霊獣使い ウェン
-- 效果：
-- 自己对「灵兽使 文」1回合只能有1次特殊召唤。
-- ①：这张卡召唤的场合，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
function c40907115.initial_effect(c)
	c:SetSPSummonOnce(40907115)
	-- ①：这张卡召唤的场合，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40907115,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40907115.sptg)
	e1:SetOperation(c40907115.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的除外状态的灵兽怪兽
function c40907115.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的取对象判定和条件判断
function c40907115.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c40907115.filter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足条件的除外灵兽怪兽数量大于0
		and Duel.IsExistingTarget(c40907115.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外灵兽怪兽作为对象
	local g=Duel.SelectTarget(tp,c40907115.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时执行特殊召唤
function c40907115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
