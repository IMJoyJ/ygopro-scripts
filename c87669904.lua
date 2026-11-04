--双天招来
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡，在自己场上把「双天魂衍生物」（战士族·光·2星·攻/守0）尽可能特殊召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤，自己场上的衍生物不能解放并在结束阶段破坏。那之后，以下效果可以适用最多2次。
-- ●从自己的手卡·场上把「双天」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c87669904.initial_effect(c)
	-- ①：丢弃1张手卡，在自己场上把「双天魂衍生物」（战士族·光·2星·攻/守0）尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_HANDES_SELF+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87669904+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87669904.target)
	e1:SetOperation(c87669904.activate)
	c:RegisterEffect(e1)
end
-- 过滤不受效果影响的融合素材
function c87669904.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可特殊召唤的「双天」融合怪兽
function c87669904.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x14f) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 确认是否有可丢弃的手卡及场上空位
function c87669904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取主要怪兽区空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查手卡是否有可丢弃的卡且场上有空位
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT) and ft>0
		-- 检查是否可以特殊召唤「双天魂衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,0,0)
	-- 设置操作信息：生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	-- 设置操作信息：丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	-- 设置操作信息：从额外卡组特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 丢弃手卡、特殊召唤衍生物、施加自肃并进行最多2次融合召唤
function c87669904.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=0
	-- 丢弃1张手卡作为效果处理
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)~=0 then
		-- 获取可用怪兽区数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查怪兽区空位及衍生物特招合法性
		if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			for i=1,ft do
				-- 创建「双天魂衍生物」
				local token=Duel.CreateToken(tp,87669905)
				-- 特殊召唤衍生物并设置融合召唤次数上限
				if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) and count==0 then
					count=2
				end
			end
			-- 完成衍生物特殊召唤
			Duel.SpecialSummonComplete()
		end
	end
	-- 自己场上的衍生物并在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c87669904.desop)
	-- 注册结束阶段破坏衍生物的效果
	Duel.RegisterEffect(e1,tp)
	-- 自己场上的衍生物不能解放
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	-- 设置不能解放的目标为衍生物
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN))
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册衍生物不能作为上级召唤解放
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	-- 注册衍生物不能作为上级召唤以外的解放
	Duel.RegisterEffect(e3,tp)
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤，那之后，以下效果可以适用最多2次。●从自己的手卡·场上把「双天」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(c87669904.splimit)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤非融合怪兽的效果
	Duel.RegisterEffect(e4,tp)
	while count>0 do
		local chkf=tp
		-- 获取手卡·场上的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(c87669904.filter1,nil,e)
		-- 获取可融合召唤的「双天」怪兽
		local sg1=Duel.GetMatchingGroup(c87669904.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取连锁素材可融合召唤的怪兽
			sg2=Duel.GetMatchingGroup(c87669904.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		-- 由玩家选择是否进行融合召唤
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(87669904,0)) then  --"是否要融合召唤？"
			-- 中断效果处理
			Duel.BreakEffect()
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断使用手卡·场上素材还是连锁素材
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 选择融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将融合素材送去墓地
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断效果处理
				Duel.BreakEffect()
				-- 将选中的融合怪兽融合召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 使用连锁素材选择融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
			count=count-1
		else
			count=0
		end
	end
end
-- 结束阶段破坏场上所有衍生物
function c87669904.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有衍生物
	local tg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,0,nil,TYPE_TOKEN)
	-- 破坏衍生物
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 限制只能从额外卡组特殊召唤融合怪兽
function c87669904.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
