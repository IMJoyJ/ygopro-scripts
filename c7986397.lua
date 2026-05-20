--リヴェンデット・バース
-- 效果：
-- 「复仇死者」仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从卡组把「复仇死者」怪兽（最多1只）送去墓地，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。这个效果仪式召唤的怪兽在下个回合的结束阶段破坏。
function c7986397.initial_effect(c)
	-- 「复仇死者」仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。①：等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而从卡组把「复仇死者」怪兽（最多1只）送去墓地，从自己的手卡·墓地把1只「复仇死者」仪式怪兽仪式召唤。这个效果仪式召唤的怪兽在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7986397+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c7986397.target)
	e1:SetOperation(c7986397.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以送去墓地的等级1以上的「复仇死者」怪兽
function c7986397.dfilter(c)
	return c:IsSetCard(0x106) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
-- 过滤「复仇死者」仪式怪兽
function c7986397.filter(c,e,tp)
	return c:IsSetCard(0x106)
end
-- 限制仪式素材中来自卡组的怪兽最多为1只
function c7986397.rcheck(tp,g,c)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 限制仪式素材中来自卡组的怪兽最多为1只（用于全局附加检查）
function c7986397.rgcheck(g,ec)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
-- 效果发动的目标确认与合法性检查，设置操作信息
function c7986397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用于仪式召唤的常规素材（手卡·场上）
		local mg=Duel.GetRitualMaterial(tp)
		-- 获取卡组中满足条件的「复仇死者」怪兽作为可选的替代素材
		local dg=Duel.GetMatchingGroup(c7986397.dfilter,tp,LOCATION_DECK,0,nil)
		-- 注册仪式召唤素材的额外限制检查函数（卡组素材最多1只）
		aux.RCheckAdditional=c7986397.rcheck
		-- 注册仪式召唤素材组的额外限制检查函数（卡组素材最多1只）
		aux.RGCheckAdditional=c7986397.rgcheck
		-- 检查手卡·墓地是否存在可以进行仪式召唤的「复仇死者」仪式怪兽（等级合计必须严格相等）
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c7986397.filter,e,tp,mg,dg,Card.GetLevel,"Equal")
		-- 重置仪式召唤素材的额外限制检查函数
		aux.RCheckAdditional=nil
		-- 重置仪式召唤素材组的额外限制检查函数
		aux.RGCheckAdditional=nil
		return res
	end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理，执行仪式召唤并注册下个回合结束阶段破坏的效果
function c7986397.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用于仪式召唤的常规素材（手卡·场上）
	local m=Duel.GetRitualMaterial(tp)
	-- 获取卡组中满足条件的「复仇死者」怪兽作为可选的替代素材
	local dg=Duel.GetMatchingGroup(c7986397.dfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 注册仪式召唤素材的额外限制检查函数（卡组素材最多1只）
	aux.RCheckAdditional=c7986397.rcheck
	-- 注册仪式召唤素材组的额外限制检查函数（卡组素材最多1只）
	aux.RGCheckAdditional=c7986397.rgcheck
	-- 玩家选择1只手卡·墓地的「复仇死者」仪式怪兽（受王家长眠之谷影响）
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c7986397.filter,e,tp,m,dg,Card.GetLevel,"Equal")
	local tc=tg:GetFirst()
	if tc then
		local mg=m:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(dg)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的仪式素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 注册仪式素材选择的等级合计检查函数（等级合计必须严格相等）
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 玩家选择满足等级合计要求的仪式素材组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 重置仪式素材选择的等级合计检查函数
		aux.GCheckAdditional=nil
		if not mat then
			-- 重置仪式召唤素材的额外限制检查函数（在取消选择时）
			aux.RCheckAdditional=nil
			-- 重置仪式召唤素材组的额外限制检查函数（在取消选择时）
			aux.RGCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			-- 将选作替代素材的卡组怪兽送去墓地
			Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 解放选中的手卡·场上的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续的特殊召唤不与送墓/解放同时处理
		Duel.BreakEffect()
		-- 将选定的仪式怪兽以仪式召唤的方式表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		tc:RegisterFlagEffect(7986397,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 这个效果仪式召唤的怪兽在下个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(c7986397.descon)
		e1:SetOperation(c7986397.desop)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 将当前回合数记录在效果的Label中，用于判断是否到了下个回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		-- 注册该回合结束阶段破坏怪兽的全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 重置仪式召唤素材的额外限制检查函数
	aux.RCheckAdditional=nil
	-- 重置仪式召唤素材组的额外限制检查函数
	aux.RGCheckAdditional=nil
end
-- 破坏效果的发动条件：当前回合不是召唤时的回合，且该怪兽仍带有对应的标记
function c7986397.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查当前回合数是否不等于召唤时的回合数（即已进入下个回合），且怪兽身上的标记依然存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(7986397)~=0
end
-- 破坏效果的具体操作：破坏该仪式怪兽
function c7986397.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将该仪式怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
