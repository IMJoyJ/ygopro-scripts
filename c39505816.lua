--炎天禍サンバーン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的炎属性怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选那1只破坏的自己墓地的炎属性怪兽，给与对方那个攻击力一半数值的伤害。
function c39505816.initial_effect(c)
	-- 创建一个诱发选发效果，当自己场上的炎属性怪兽被战斗或对方的效果破坏时可以发动，将此卡从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39505816,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39505816)
	e1:SetCondition(c39505816.spcon)
	e1:SetTarget(c39505816.sptg)
	e1:SetOperation(c39505816.spop)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于判断被破坏的怪兽是否为自己的场上表侧表示的炎属性怪兽，并且是由战斗或对方效果破坏的
function c39505816.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_FIRE)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 条件函数，判断是否有满足条件的怪兽被破坏
function c39505816.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39505816.cfilter,1,nil,tp)
end
-- 目标函数，检查是否可以将此卡特殊召唤
function c39505816.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 伤害过滤器函数，用于筛选自己墓地中的炎属性怪兽
function c39505816.damfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetAttack()>0 and c39505816.cfilter(c,tp)
end
-- 效果处理函数，将此卡特殊召唤到场上，并可选择墓地中的炎属性怪兽给予对方伤害
function c39505816.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=eg:Filter(c39505816.damfilter,nil,tp)
	-- 执行特殊召唤操作，将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 判断墓地是否有符合条件的怪兽且玩家选择给予伤害
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39505816,1)) then  --"是否给与对方伤害？"
		-- 提示玩家选择墓地中的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 对对方造成该怪兽攻击力一半的伤害
		Duel.Damage(1-tp,math.ceil(sg:GetFirst():GetAttack()/2),REASON_EFFECT)
	end
end
