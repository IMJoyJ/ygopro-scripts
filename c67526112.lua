--ラピッド・トリガー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：融合怪兽卡决定的自己场上的融合素材怪兽破坏，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只能向从额外卡组特殊召唤的怪兽攻击，不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
function c67526112.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：融合怪兽卡决定的自己场上的融合素材怪兽破坏，把那1只融合怪兽从额外卡组融合召唤。这个效果特殊召唤的怪兽只能向从额外卡组特殊召唤的怪兽攻击，不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67526112,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,67526112+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c67526112.target)
	e1:SetOperation(c67526112.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤出场上可以被效果破坏的卡片
function c67526112.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e) and c:IsDestructable(e)
end
-- 过滤函数：过滤出额外卡组中可以进行融合召唤的怪兽
function c67526112.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动阶段的合法性检查与操作信息注册
function c67526112.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组中是否存在可以使用场上素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c67526112.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果适用下，检查额外卡组中是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c67526112.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：特殊召唤额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：破坏场上的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
-- 效果处理：将场上的融合素材破坏，并从额外卡组融合召唤，同时赋予其攻击限制和效果免疫
function c67526112.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取自己场上可被效果破坏的融合素材卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c67526112.filter1,nil,e)
	-- 获取额外卡组中可以使用场上素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c67526112.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 在连锁素材效果适用下，获取额外卡组中可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c67526112.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		local res=false
		-- 判断是否使用本卡自身的效果进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择场上的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 破坏选中的融合素材，并检查是否全部破坏成功
			if Duel.Destroy(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==#mat1 then
				-- 中断当前效果处理，使后续的特殊召唤与破坏不视为同时处理
				Duel.BreakEffect()
				-- 将融合怪兽从额外卡组融合召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				res=true
			end
		else
			-- 在适用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			res=true
		end
		if res then
			tc:CompleteProcedure()
			-- 这个效果特殊召唤的怪兽只能向从额外卡组特殊召唤的怪兽攻击
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_SINGLE)
			e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e0,true)
			-- 这个效果特殊召唤的怪兽只能向从额外卡组特殊召唤的怪兽攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetValue(c67526112.bttg)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 不受从额外卡组特殊召唤的其他怪兽发动的效果影响
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetValue(c67526112.immval)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(67526112,1))  --"「速射扳机」效果适用中"
		end
	end
end
-- 攻击目标限制：不能选择非额外卡组特殊召唤的怪兽作为攻击对象
function c67526112.bttg(e,c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果免疫判定：不受从额外卡组特殊召唤的其他怪兽在场上发动的效果影响
function c67526112.immval(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
