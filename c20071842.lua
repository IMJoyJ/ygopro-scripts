--ヘヴィ・トリガー
-- 效果：
-- 「装弹枪管暴动龙」的降临必需。
-- ①：等级合计直到8以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己的手卡·场上的「弹丸」怪兽破坏，从手卡把「装弹枪管暴动龙」仪式召唤。这个效果特殊召唤的怪兽不会被和从额外卡组特殊召唤的怪兽的战斗破坏，不受从额外卡组特殊召唤的怪兽发动的效果影响。
function c20071842.initial_effect(c)
	-- 记录此卡与「装弹枪管暴动龙」的关联
	aux.AddCodeList(c,7987191)
	-- ①：等级合计直到8以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己的手卡·场上的「弹丸」怪兽破坏，从手卡把「装弹枪管暴动龙」仪式召唤。这个效果特殊召唤的怪兽不会被和从额外卡组特殊召唤的怪兽的战斗破坏，不受从额外卡组特殊召唤的怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20071842,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20071842.target)
	e1:SetOperation(c20071842.activate)
	c:RegisterEffect(e1)
end
-- 返回仪式召唤所需等级为8
function c20071842.lv(c)
	return 8
end
-- 过滤满足条件的「装弹枪管暴动龙」
function c20071842.filter(c,e,tp)
	return c:IsCode(7987191)
end
-- 过滤满足条件的「弹丸」怪兽
function c20071842.mfilter(c,e)
	return c:IsLevelAbove(0) and c:IsSetCard(0x102) and c:IsDestructable(e)
end
-- 检查是否存在满足仪式召唤条件的素材
function c20071842.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的用于仪式召唤的素材组（手牌和场上可解放的怪兽）
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取玩家手牌和场上的「弹丸」怪兽组
		local mg2=Duel.GetMatchingGroup(c20071842.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		-- 检查是否存在满足仪式召唤条件的「装弹枪管暴动龙」
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c20071842.filter,e,tp,mg1,mg2,c20071842.lv,"Greater")
	end
	-- 设置操作信息：特殊召唤目标为手牌中的「装弹枪管暴动龙」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：破坏目标为手牌和场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- 处理仪式召唤流程
function c20071842.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的用于仪式召唤的素材组（手牌和场上可解放的怪兽）
	local mg1=Duel.GetRitualMaterial(tp)
	-- 获取玩家手牌和场上的「弹丸」怪兽组
	local mg2=Duel.GetMatchingGroup(c20071842.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	-- 提示玩家选择要特殊召唤的「装弹枪管暴动龙」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的「装弹枪管暴动龙」
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c20071842.filter,e,tp,mg1,mg2,c20071842.lv,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放或破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(20071842,1))  --"请选择要解放或破坏的怪兽"
		-- 设置额外的仪式召唤等级检查条件
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,8,"Greater")
		-- 从可用素材中选择满足等级要求的组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,8,tp,tc,8,"Greater")
		-- 清除额外的仪式召唤等级检查条件
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 统计所选素材中来自手牌和场上的数量
		local ct1=mat:FilterCount(aux.IsInGroup,nil,mg1)
		-- 统计所选素材中来自「弹丸」怪兽的数量
		local ct2=mat:FilterCount(aux.IsInGroup,nil,mg2)
		local dg=mat-mg1
		local mat1=mat:Clone()
		local mat2
		if ct1==0 then
			mat2=mat
			mat1:Clear()
		-- 判断是否选择「弹丸」怪兽进行破坏
		elseif ct2>0 and (#dg>0 or Duel.SelectYesNo(tp,aux.Stringid(20071842,2))) then  --"是否选择「弹丸」怪兽破坏？"
			local min=math.max(#dg,1)
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			mat2=mat:SelectSubGroup(tp,c20071842.descheck,false,min,#mat,mg2,dg)
			mat1:Sub(mat2)
		end
		if #mat1>0 then
			-- 解放所选的仪式素材
			Duel.ReleaseRitualMaterial(mat1)
		end
		if mat2 then
			-- 确认对方玩家看到被破坏的卡
			Duel.ConfirmCards(1-tp,mat2)
			-- 破坏所选的「弹丸」怪兽
			Duel.Destroy(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将「装弹枪管暴动龙」特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		-- 设置特殊召唤的「装弹枪管暴动龙」获得不会被从额外卡组特殊召唤的怪兽战斗破坏的效果和不受从额外卡组特殊召唤的怪兽发动的效果影响的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c20071842.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c20071842.immval)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(20071842,3))  --"「重型扳机」效果适用中"
	end
end
-- 定义用于检查素材组合是否满足破坏条件的函数
function c20071842.descheck(g,mg2,dg)
	-- 检查所选素材是否全部来自「弹丸」怪兽且「弹丸」怪兽组中所有卡都被选中
	return g:FilterCount(aux.IsInGroup,nil,dg)==#dg and mg2:FilterCount(aux.IsInGroup,nil,g)==#g
end
-- 定义特殊召唤的「装弹枪管暴动龙」不会被从额外卡组特殊召唤的怪兽战斗破坏的判断条件
function c20071842.indval(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 定义特殊召唤的「装弹枪管暴动龙」不受从额外卡组特殊召唤的怪兽发动的效果影响的判断条件
function c20071842.immval(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
