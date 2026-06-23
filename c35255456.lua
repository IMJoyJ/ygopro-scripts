--ミラクル・コンタクト
-- 效果：
-- ①：从自己的手卡·场上·墓地让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「元素英雄 新宇侠」为融合素材的那1只「元素英雄」融合怪兽无视召唤条件从额外卡组特殊召唤。
function c35255456.initial_effect(c)
	-- 记录此卡与「元素英雄 新宇侠」的卡名关联
	aux.AddCodeList(c,89943723)
	-- 为该卡添加「元素英雄」系列编码
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己的手卡·场上·墓地让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「元素英雄 新宇侠」为融合素材的那1只「元素英雄」融合怪兽无视召唤条件从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35255456.target)
	e1:SetOperation(c35255456.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的卡：可以送入卡组且未被效果免疫
function c35255456.filter1(c,e)
	return c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤满足条件的卡：属于「元素英雄」系列、是融合怪兽、以「元素英雄 新宇侠」为融合素材、可以特殊召唤
function c35255456.filter2(c,e,tp,m,chkf)
	-- 判断怪兽是否以「元素英雄 新宇侠」为融合素材
	return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 判断是否满足发动条件：从额外卡组中存在符合条件的融合怪兽
function c35255456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取玩家手牌、墓地、场上的满足条件的卡组
		local mg=Duel.GetMatchingGroup(c35255456.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
		-- 检查是否存在满足条件的融合怪兽
		return Duel.IsExistingMatchingCard(c35255456.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 设置操作信息：准备特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤满足条件的卡：在手牌或在场且是里侧表示的卡
function c35255456.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 执行效果处理：选择并特殊召唤融合怪兽
function c35255456.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 获取玩家手牌、墓地、场上的满足条件的卡组（排除王家长眠之谷影响）
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c35255456.filter1),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
	-- 获取玩家额外卡组中满足条件的融合怪兽组
	local sg=Duel.GetMatchingGroup(c35255456.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 选择融合怪兽的融合素材
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		local cf=mat:Filter(c35255456.cffilter,nil)
		if cf:GetCount()>0 then
			-- 确认对方能看到融合素材中的手牌或里侧表示的卡
			Duel.ConfirmCards(1-tp,cf)
		end
		-- 将融合素材送入卡组并洗牌
		Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 无视召唤条件将融合怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
