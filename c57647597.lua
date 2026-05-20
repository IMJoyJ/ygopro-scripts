--レプティレス・ヒュドラ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡存在，自己场上的怪兽只有爬虫类族怪兽的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡特殊召唤。那之后，自己受到那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡作为同调素材送去墓地的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽的攻击力变成0。
function c57647597.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上的怪兽只有爬虫类族怪兽的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，这张卡特殊召唤。那之后，自己受到那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57647597,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57647597)
	e1:SetCondition(c57647597.spcon)
	e1:SetTarget(c57647597.sptg)
	e1:SetOperation(c57647597.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以场上最多2只表侧表示怪兽为对象才能发动。那些怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57647597,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,57647597)
	e2:SetCondition(c57647597.atkcon)
	e2:SetTarget(c57647597.atktg)
	e2:SetOperation(c57647597.atkop)
	c:RegisterEffect(e2)
end
-- 过滤非表侧表示或非爬虫类族的怪兽（用于检测自己场上是否“只有爬虫类族怪兽”）
function c57647597.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_REPTILE)
end
-- 效果①的发动条件：自己场上有怪兽存在，且只有表侧表示的爬虫类族怪兽
function c57647597.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽区域的卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 且不存在里侧表示怪兽或非爬虫类族的怪兽（即自己场上的怪兽只有爬虫类族怪兽）
		and not Duel.IsExistingMatchingCard(c57647597.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤攻击力不为0且原本攻击力大于0的表侧表示怪兽（作为效果①的对象过滤条件）
function c57647597.spfilter(c)
	-- 过滤表侧表示、攻击力大于0且原本攻击力大于0的怪兽
	return aux.nzatk(c) and c:GetBaseAttack()>0
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象、设置操作信息）
function c57647597.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c57647597.spfilter(chkc) end
	-- 检查自己场上是否有空余的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且对方场上存在满足条件的表侧表示怪兽
		and Duel.IsExistingTarget(c57647597.spfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57647597.spfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置伤害的操作信息（自己受到该怪兽原本攻击力数值的伤害）
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,atk)
end
-- 效果①的处理（将对象怪兽攻击力变0，特殊召唤自身，之后自己受到伤害）
function c57647597.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力变成0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local atk=math.max(tc:GetBaseAttack(),0)
		-- 检查自身是否仍与效果相关，若成功特殊召唤且对象怪兽原本攻击力大于0，则继续处理伤害
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and atk>0 then
			-- 中断效果处理，使后续的伤害处理与特殊召唤不视为同时进行（对应“那之后”）
			Duel.BreakEffect()
			-- 自己受到该怪兽原本攻击力数值的效果伤害
			Duel.Damage(tp,atk,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：这张卡作为同调素材送去墓地的场合
function c57647597.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果②的发动准备（检查并选择场上最多2只表侧表示怪兽作为对象）
function c57647597.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对象是否是场上表侧表示且攻击力不为0的怪兽（重构/检查对象时使用）
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.nzatk(chkc) end
	-- 检查场上是否存在至少1只表侧表示且攻击力不为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1到2只表侧表示且攻击力不为0的怪兽作为对象
	Duel.SelectTarget(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
end
-- 过滤出仍表侧表示且与当前效果相关的对象怪兽
function c57647597.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果②的处理（将选择的对象怪兽的攻击力变成0）
function c57647597.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍表侧表示且与效果相关的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c57647597.tgfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的攻击力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
