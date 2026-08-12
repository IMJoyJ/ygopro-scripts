--デス・クラーケン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有「海」存在的场合，以「死亡乌贼」以外的自己场上1只水属性怪兽和对方场上1只怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的自己怪兽回到持有者手卡，作为对象的对方怪兽破坏。这个效果在对方回合也能发动。
-- ②：对方怪兽的攻击宣言时才能发动。这张卡回到持有者手卡，那次攻击无效。
function c69436288.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果记有「海」的卡名。
	aux.AddCodeList(c,22702055)
	-- ①：场上有「海」存在的场合，以「死亡乌贼」以外的自己场上1只水属性怪兽和对方场上1只怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的自己怪兽回到持有者手卡，作为对象的对方怪兽破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69436288,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,69436288)
	e1:SetCondition(c69436288.spcon)
	e1:SetTarget(c69436288.sptg)
	e1:SetOperation(c69436288.spop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时才能发动。这张卡回到持有者手卡，那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69436288,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,69436289)
	e2:SetCondition(c69436288.thcon)
	e2:SetTarget(c69436288.thtg)
	e2:SetOperation(c69436288.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数：场上有「海」存在。
function c69436288.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上（或作为场地卡使用）是否存在卡名视为「海」的卡。
	return Duel.IsEnvironment(22702055)
end
-- 过滤条件：场上表侧表示的、除「死亡乌贼」以外的水属性且能回到手牌的怪兽。
function c69436288.thfilter(c)
	return c:IsFaceup() and not c:IsCode(69436288) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择函数。
function c69436288.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只满足条件的、可作为对象的水属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c69436288.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在1只可作为对象的怪兽。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的水属性怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c69436288.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：预估操作为将选中的自己怪兽送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
	-- 设置连锁信息：预估操作为破坏选中的对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
	-- 设置连锁信息：预估操作为特殊召唤手牌中的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数。
function c69436288.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的所有卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 尝试将这张卡特殊召唤，若特殊召唤成功则继续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=g:GetFirst()
		if tc==hc then tc=g:GetNext() end
		if hc:IsRelateToEffect(e) and hc:IsControler(tp)
			-- 尝试将作为对象的自己怪兽送回手牌，并确认其已成功到达手牌。
			and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND)
			and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
			-- 破坏作为对象的对方怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件函数：对方怪兽进行攻击宣言。
function c69436288.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前发动攻击的怪兽是否由对方玩家控制。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果②的发动准备与目标选择函数。
function c69436288.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁信息：预估操作为将这张卡送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数。
function c69436288.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果关联，并尝试将其送回手牌，确认其已成功回到手牌。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 使那次攻击无效。
		Duel.NegateAttack()
	end
end
