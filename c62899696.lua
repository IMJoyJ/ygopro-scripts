--SRアクマグネ
-- 效果：
-- 「疾行机人 磁铁恶魔」的效果1回合只能使用1次。这张卡不用这张卡的效果的同调召唤不能作为同调素材。
-- ①：这张卡在自己主要阶段召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材把1只风属性同调怪兽同调召唤。
function c62899696.initial_effect(c)
	-- 这张卡不用这张卡的效果的同调召唤不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c62899696.smcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 「疾行机人 磁铁恶魔」的效果1回合只能使用1次。①：这张卡在自己主要阶段召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材把1只风属性同调怪兽同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62899696,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,62899696)
	e2:SetCondition(c62899696.spcon)
	e2:SetTarget(c62899696.sptg)
	e2:SetOperation(c62899696.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 同调素材限制效果的启用条件判定（若未注册FlagEffect，即不是通过自身效果进行同调召唤时，不能作为同调素材）
function c62899696.smcon(e)
	return e:GetHandler():GetFlagEffect(62899696)==0
end
-- 效果发动的条件判定（自己回合的主要阶段）
function c62899696.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 判定当前阶段是否为主要阶段1或主要阶段2
		and bit.band(Duel.GetCurrentPhase(),PHASE_MAIN1+PHASE_MAIN2)>0
end
-- 过滤对方场上可以作为同调素材，且能与这张卡一起作为素材同调召唤额外卡组中风属性同调怪兽的表侧表示怪兽
function c62899696.filter(tc,c,tp)
	if tc:IsFacedown() or not tc:IsCanBeSynchroMaterial() then return false end
	c:RegisterFlagEffect(62899696,0,0,1)
	local mg=Group.FromCards(c,tc)
	-- 检查额外卡组是否存在可以使用指定素材进行同调召唤的风属性同调怪兽
	local res=Duel.IsExistingMatchingCard(c62899696.synfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	c:ResetFlagEffect(62899696)
	return res
end
-- 过滤额外卡组中可以使用指定素材进行同调召唤的风属性同调怪兽
function c62899696.synfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSynchroSummonable(nil,mg)
end
-- 效果发动的对象选择与特殊召唤操作信息注册
function c62899696.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c62899696.filter(chkc,e:GetHandler(),tp) end
	-- 在发动效果的准备阶段，检查对方场上是否存在满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c62899696.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler(),tp) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c62899696.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler(),tp)
	-- 设置效果处理时的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的核心逻辑：验证卡片状态，临时允许自身作为同调素材，并使用自身和对象怪兽进行同调召唤
function c62899696.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:RegisterFlagEffect(62899696,RESET_EVENT+RESETS_STANDARD,0,1)
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只可以使用当前素材进行同调召唤的风属性同调怪兽
		local g=Duel.SelectMatchingCard(tp,c62899696.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			-- 使用指定的素材将选定的同调怪兽进行同调召唤
			Duel.SynchroSummon(tp,sc,nil,mg)
		else
			c:ResetFlagEffect(62899696)
		end
	end
end
