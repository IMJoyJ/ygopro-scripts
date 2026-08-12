--トゥーン・ハーピィ・レディ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「卡通世界」存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有其他的卡通怪兽存在的场合，可以再选对方场上1张魔法·陷阱卡破坏。
-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
function c64116319.initial_effect(c)
	-- 在卡片中注册记有「卡通世界」卡名的信息
	aux.AddCodeList(c,15259703)
	-- ①：自己场上有「卡通世界」存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有其他的卡通怪兽存在的场合，可以再选对方场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64116319,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,64116319)
	e1:SetCondition(c64116319.spcon1)
	e1:SetTarget(c64116319.sptg1)
	e1:SetOperation(c64116319.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c64116319.atklimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c64116319.dircon)
	c:RegisterEffect(e5)
end
-- 召唤、反转召唤、特殊召唤成功时，为自身添加在该回合不能攻击的效果
function c64116319.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：表侧表示的「卡通世界」
function c64116319.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：表侧表示的卡通怪兽
function c64116319.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 直接攻击效果的允许条件：自己场上有「卡通世界」且对方场上没有卡通怪兽
function c64116319.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c64116319.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 且对方场上不存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c64116319.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤效果的发动条件：自己场上有「卡通世界」存在
function c64116319.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c64116319.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否可特殊召唤，并设置操作信息
function c64116319.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为：特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：特殊召唤自身，若满足条件则可选择是否破坏对方场上1张魔法·陷阱卡
function c64116319.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上的所有魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		-- 判断对方场上是否存在魔法·陷阱卡，且自己场上是否存在除自身以外的其他卡通怪兽
		if #g>0 and Duel.IsExistingMatchingCard(c64116319.cfilter2,tp,LOCATION_ONFIELD,0,1,c)
			-- 询问玩家是否选择破坏对方场上1张魔法·陷阱卡
			and Duel.SelectYesNo(tp,aux.Stringid(64116319,1)) then  --"是否选对方场上1张魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 显式展示被选择的卡片
			Duel.HintSelection(sg)
			-- 因效果破坏所选的卡片
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
