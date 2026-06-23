--ドラゴンメイドのお召し替え
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只龙族融合怪兽融合召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只「半龙女仆」怪兽为对象才能发动。这张卡加入手卡，那只怪兽回到手卡。
function c40110009.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只龙族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40110009,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40110009.target)
	e1:SetOperation(c40110009.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只「半龙女仆」怪兽为对象才能发动。这张卡加入手卡，那只怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40110009,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,40110009)
	e2:SetTarget(c40110009.thtg)
	e2:SetOperation(c40110009.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否免疫当前效果
function c40110009.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断是否为龙族融合怪兽且满足特殊召唤条件
function c40110009.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理时检查是否存在满足条件的融合怪兽
function c40110009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c40110009.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查额外卡组中是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c40110009.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理函数
function c40110009.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材，排除免疫效果的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c40110009.filter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c40110009.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足融合召唤条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c40110009.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于判断是否为「半龙女仆」且可送入手卡
function c40110009.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x133) and c:IsAbleToHand()
end
-- 设置效果处理时的目标选择函数
function c40110009.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40110009.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 检查场上是否存在满足条件的「半龙女仆」怪兽
		and Duel.IsExistingTarget(c40110009.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c40110009.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息，指定将要送入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理函数，将卡和目标怪兽送入手卡
function c40110009.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断卡和目标怪兽是否满足效果处理条件
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
