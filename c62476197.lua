--アチャチャチャンバラー
-- 效果：
-- 给与基本分伤害的魔法·陷阱·效果怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，给与对方基本分400分伤害。
function c62476197.initial_effect(c)
	-- 给与基本分伤害的魔法·陷阱·效果怪兽的效果发动时才能发动。这张卡从手卡特殊召唤，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62476197,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c62476197.spcon)
	e1:SetTarget(c62476197.sptg)
	e1:SetOperation(c62476197.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，判断是否为给与伤害的效果发动时
function c62476197.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁中的效果是否会给与自己或对方基本分伤害
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp) or aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp)
end
-- 定义效果发动目标检测与处理函数
function c62476197.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查此卡未在连锁中、且己方怪兽区域有空位
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果处理信息：给与对方400分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 定义效果处理函数，执行特殊召唤和伤害处理
function c62476197.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将此卡表侧表示特殊召唤，若特殊召唤成功则继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 给与对方400分伤害
		Duel.Damage(1-tp,400,REASON_EFFECT)
	end
end
