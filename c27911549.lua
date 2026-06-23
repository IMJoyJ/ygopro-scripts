--寄生虫パラサイド
-- 效果：
-- 反转：把这张卡表面向上混进对方卡组洗切。对方抽到这张卡时，这张卡在对方场上表侧守备表示特殊召唤，给与对方基本分1000分伤害。之后，只要这张卡表侧表示在场上存在，对方场上表侧表示存在的怪兽全部变成昆虫族。
function c27911549.initial_effect(c)
	-- 设置全局标记，用于检测卡组翻转相关效果
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- 反转：把这张卡表面向上混进对方卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27911549,0))  --"进入对方卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c27911549.target)
	e1:SetOperation(c27911549.operation)
	c:RegisterEffect(e1)
end
-- 设置效果目标为将自身送去对方卡组
function c27911549.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将自身送去对方卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 反转效果的处理函数，将自身送去对方卡组并洗切，然后设置抽到时的特殊召唤效果
function c27911549.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	-- 将自身以效果原因送去对方卡组底部并标记需要洗切
	Duel.SendtoDeck(c,1-tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if not c:IsLocation(LOCATION_DECK) then return end
	-- 手动洗切对方卡组
	Duel.ShuffleDeck(1-tp)
	c:ReverseInDeck()
	-- 对方抽到这张卡时，这张卡在对方场上表侧守备表示特殊召唤，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27911549,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DRAW)
	e1:SetTarget(c27911549.sptg)
	e1:SetOperation(c27911549.spop)
	e1:SetReset(RESET_EVENT+0x1de0000)
	c:RegisterEffect(e1)
end
-- 设置特殊召唤效果的目标为自身
function c27911549.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将自身特殊召唤并造成伤害，再设置对方场上怪兽变为昆虫族的效果
function c27911549.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以特殊召唤方式特殊召唤到对方场上
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			-- 给与对方基本分1000分伤害
			Duel.Damage(tp,1000,REASON_EFFECT)
			-- 只要这张卡表侧表示在场上存在，对方场上表侧表示存在的怪兽全部变成昆虫族。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,LOCATION_MZONE,0)
			e1:SetValue(RACE_INSECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
