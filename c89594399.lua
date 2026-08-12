--レプティレス・コアトル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有爬虫类族·暗属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。对方场上有攻击力0的怪兽存在的场合，可以再把最多有那个数量的「爬虫妖」怪兽从手卡特殊召唤。
-- ②：把自己场上的这张卡作为爬虫类族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c89594399.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有爬虫类族·暗属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。对方场上有攻击力0的怪兽存在的场合，可以再把最多有那个数量的「爬虫妖」怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89594399)
	e1:SetCondition(c89594399.spcon)
	e1:SetTarget(c89594399.sptg)
	e1:SetOperation(c89594399.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上的这张卡作为爬虫类族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetValue(c89594399.ntval)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的爬虫类族·暗属性怪兽
function c89594399.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果①的发动条件：自己场上有爬虫类族·暗属性怪兽存在
function c89594399.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的爬虫类族·暗属性怪兽
	return Duel.IsExistingMatchingCard(c89594399.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备（检查自身能否特殊召唤并设置操作信息）
function c89594399.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（预计特殊召唤1张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：对方场上表侧表示且攻击力为0的怪兽
function c89594399.cgfilter(c)
	return c:IsFaceup() and c:IsAttack(0)
end
-- 过滤条件：手牌中可以特殊召唤的「爬虫妖」怪兽
function c89594399.spfilter(c,e,tp)
	return c:IsSetCard(0x3c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理（特殊召唤自身，并根据对方场上攻击力0的怪兽数量决定是否追加特殊召唤手牌的「爬虫妖」怪兽）
function c89594399.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手牌，则将其特殊召唤，若特殊召唤成功则进行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上所有攻击力为0的怪兽
		local cg=Duel.GetMatchingGroup(c89594399.cgfilter,tp,0,LOCATION_MZONE,nil)
		-- 计算可以追加特殊召唤的最大数量（取对方场上攻击力0的怪兽数量与自己可用怪兽区域数量的较小值）
		local ct=math.min(#cg,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		-- 获取手牌中满足特殊召唤条件的「爬虫妖」怪兽
		local g=Duel.GetMatchingGroup(c89594399.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若手牌有符合条件的怪兽且有可用位置，询问玩家是否追加特殊召唤
		if g:GetCount()>0 and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(89594399,1)) then  --"是否特殊召唤更多「爬虫妖」怪兽？"
			-- 中断当前效果，使后续的特殊召唤处理与自身的特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,ct,nil)
			-- 将选中的「爬虫妖」怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 限制条件：作为同调素材时，必须是自己场上的这张卡，且用于爬虫类族同调怪兽的同调召唤
function c89594399.ntval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsRace(RACE_REPTILE)
end
