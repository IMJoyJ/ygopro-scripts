--オルターガイスト・ドラッグウィリオン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：特殊召唤的对方怪兽的攻击宣言时，让自己场上1只「幻变骚灵」怪兽回到持有者手卡才能发动。那次攻击无效。
-- ②：这张卡被解放送去墓地的场合才能发动。这张卡特殊召唤。
function c21187631.initial_effect(c)
	-- 为这张卡添加同调召唤手续：素材为调整＋调整以外的怪兽1只以上，须通过同调召唤出场。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：特殊召唤的对方怪兽的攻击宣言时，让自己场上1只「幻变骚灵」怪兽回到持有者手卡才能发动。那次攻击无效。
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
-- 效果①的发动条件：攻击宣言的怪兽为对方控制，且是特殊召唤的怪兽。
function c21187631.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(1-tp) and tc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 代价过滤条件：自己场上的表侧表示「幻变骚灵」怪兽，且可以作为代价返回手卡。
function c21187631.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToHandAsCost()
end
-- 效果①的代价处理：选择自己场上1只表侧表示的「幻变骚灵」怪兽返回持有者手卡才能发动。
function c21187631.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在满足条件的「幻变骚灵」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21187631.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出卡片选择提示，提示玩家选择要返回手卡的「幻变骚灵」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的「幻变骚灵」怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c21187631.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的「幻变骚灵」怪兽返回持有者手卡（作为代价）。
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果①的发动处理：无效对方的攻击宣言。
function c21187631.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前那次攻击宣言。
	Duel.NegateAttack()
end
-- 效果②的发动条件：这张卡由于被解放而送去墓地。
function c21187631.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end
-- 效果②发动条件检查：自己场上有空余的怪兽区域，且这张卡可以被特殊召唤。
function c21187631.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将特殊召唤这张卡（用于连锁检测，如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②处理：这张卡被解放送去墓地后，若卡片仍与效果关联且不受王家长眠之谷影响，将其表侧表示特殊召唤。
function c21187631.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且不受王家长眠之谷影响，满足条件才进行特殊召唤。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
