--オルターガイスト・クンティエリ
-- 效果：
-- ①：自己场上有「幻变骚灵」卡存在的场合，对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
-- ②：这张卡特殊召唤成功的场合，以对方场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，那张卡的效果无效化。
function c52927340.initial_effect(c)
	-- ①：自己场上有「幻变骚灵」卡存在的场合，对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52927340,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52927340.condition)
	e1:SetTarget(c52927340.target)
	e1:SetOperation(c52927340.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，那张卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52927340,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c52927340.distg)
	e2:SetOperation(c52927340.disop)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在「幻变骚灵」卡
function c52927340.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103)
end
-- 效果条件判断：攻击方为对方且己方场上有幻变骚灵卡
function c52927340.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	-- 判断攻击方是否为对方且己方场上有幻变骚灵卡
	return at:IsControler(1-tp) and Duel.IsExistingMatchingCard(c52927340.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理目标
function c52927340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查是否有足够的召唤区域并满足特殊召唤条件
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 发动效果时执行的操作
function c52927340.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡能被特殊召唤且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 无效此次攻击
		Duel.NegateAttack()
	end
end
-- 设置无效化对象的选择处理
function c52927340.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断选择的目标是否为对方场上的表侧表示卡
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在符合条件的对方场上表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效化的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一张对方场上的表侧表示卡作为目标
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：使目标卡效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行无效化效果的操作
function c52927340.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 创建一个使目标卡效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c52927340.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
	end
end
-- 判断目标卡是否被此卡作为对象
function c52927340.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
