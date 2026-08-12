--オルターガイスト・ドラッグウィリオン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：特殊召唤的对方怪兽的攻击宣言时，让自己场上1只「幻变骚灵」怪兽回到持有者手卡才能发动。那次攻击无效。
-- ②：这张卡被解放送去墓地的场合才能发动。这张卡特殊召唤。
function c21187631.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：特殊召唤的对方怪兽的攻击宣言时，让自己场上1只「幻变骚灵」怪兽回到持有者手卡才能发动。那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21187631,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,21187631)
	e1:SetCondition(c21187631.atkcon)
	e1:SetCost(c21187631.atkcost)
	e1:SetOperation(c21187631.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放送去墓地的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21187631,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,21187632)
	e2:SetCondition(c21187631.spcon)
	e2:SetTarget(c21187631.sptg)
	e2:SetOperation(c21187631.spop)
	c:RegisterEffect(e2)
end
-- 攻击宣言时的触发条件：攻击怪兽是对方特殊召唤的
function c21187631.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(1-tp) and tc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤满足条件的「幻变骚灵」怪兽（正面表示且能送入手牌）
function c21187631.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToHandAsCost()
end
-- 支付代价：选择1只场上正面表示的「幻变骚灵」怪兽送入手牌
function c21187631.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21187631.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「幻变骚灵」怪兽
	local g=Duel.SelectMatchingCard(tp,c21187631.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽送入手牌作为代价
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果处理：无效此次攻击
function c21187631.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
-- 特殊召唤的触发条件：此卡因解放而送去墓地
function c21187631.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end
-- 特殊召唤的发动准备：检查是否能特殊召唤此卡
function c21187631.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤
function c21187631.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上且未受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
