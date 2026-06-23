--音速を追う者
-- 效果：
-- 「跨音速鸟」的降临必需。这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到4以上的自己的手卡·场上的怪兽解放，从手卡把「跨音速鸟」仪式召唤。这个效果特殊召唤的怪兽的等级变成那次仪式召唤使用的怪兽的等级合计的等级。
-- ②：把墓地的这张卡除外，以自己场上1只仪式怪兽为对象才能发动。种族或者属性和那只怪兽相同的1只仪式怪兽从卡组送去墓地。
function c17888577.initial_effect(c)
	-- 记录此卡与「跨音速鸟」的关联
	aux.AddCodeList(c,34072799)
	-- ①：等级合计直到4以上的自己的手卡·场上的怪兽解放，从手卡把「跨音速鸟」仪式召唤。这个效果特殊召唤的怪兽的等级变成那次仪式召唤使用的怪兽的等级合计的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17888577,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17888577.target)
	e1:SetOperation(c17888577.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只仪式怪兽为对象才能发动。种族或者属性和那只怪兽相同的1只仪式怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17888577,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,17888577)
	e2:SetTarget(c17888577.tgtg)
	e2:SetOperation(c17888577.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选「跨音速鸟」
function c17888577.filter(c,e,tp)
	return c:IsCode(34072799)
end
-- 检查是否满足仪式召唤条件
function c17888577.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材组
		local mg=Duel.GetRitualMaterial(tp)
		-- 检查是否存在满足仪式召唤条件的怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c17888577.filter,e,tp,mg,nil,Card.GetLevel,"Greater")
	end
	-- 设置效果处理信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理仪式召唤效果
function c17888577.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的仪式召唤素材组
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c17888577.filter,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的仪式召唤等级检查条件
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从素材组中选择满足条件的组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除额外的仪式召唤等级检查条件
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local lv=mat:GetSum(Card.GetLevel)
		-- 解放选中的仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 特殊召唤选中的仪式怪兽
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			-- 将特殊召唤的怪兽等级设为使用的怪兽等级合计
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:CompleteProcedure()
		end
		-- 完成特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
-- 检查目标怪兽是否满足条件
function c17888577.checkfilter(c,tp)
	local att=c:GetAttribute()
	local race=c:GetRace()
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
		-- 检查是否存在满足条件的卡组怪兽
		and Duel.IsExistingMatchingCard(c17888577.tgfilter,tp,LOCATION_DECK,0,1,nil,att,race)
end
-- 过滤函数，用于筛选种族或属性相同的仪式怪兽
function c17888577.tgfilter(c,att,race)
	return bit.band(c:GetType(),0x81)==0x81 and (c:IsAttribute(att) or c:IsRace(race)) and c:IsAbleToGrave()
end
-- 设置效果处理信息，表示将送去墓地
function c17888577.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c17888577.checkfilter(chkc,tp) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c17888577.checkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c17888577.checkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息，表示将送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动
function c17888577.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=tc:GetAttribute()
		local race=tc:GetRace()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的卡组怪兽
		local g=Duel.SelectMatchingCard(tp,c17888577.tgfilter,tp,LOCATION_DECK,0,1,1,nil,att,race)
		if g:GetCount()>0 then
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
