--音速を追う者
-- 效果：
-- 「跨音速鸟」的降临必需。这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到4以上的自己的手卡·场上的怪兽解放，从手卡把「跨音速鸟」仪式召唤。这个效果特殊召唤的怪兽的等级变成那次仪式召唤使用的怪兽的等级合计的等级。
-- ②：把墓地的这张卡除外，以自己场上1只仪式怪兽为对象才能发动。种族或者属性和那只怪兽相同的1只仪式怪兽从卡组送去墓地。
function c17888577.initial_effect(c)
	-- 将卡名“跨音速鸟”的卡号34072799记录到本卡的代码列表中，表示本卡记述了该卡名，供检索/判定相关效果使用。
	aux.AddCodeList(c,34072799)
	-- 对应①效果：“等级合计直到4以上的自己的手卡·场上的怪兽解放，从手卡把「跨音速鸟」仪式召唤。这个效果特殊召唤的怪兽的等级变成那次仪式召唤使用的怪兽的等级合计的等级。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17888577,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17888577.target)
	e1:SetOperation(c17888577.activate)
	c:RegisterEffect(e1)
	-- 对应②效果：“把墓地的这张卡除外，以自己场上1只仪式怪兽为对象才能发动。种族或者属性和那只怪兽相同的1只仪式怪兽从卡组送去墓地。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17888577,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果发动时的COST：将墓地中的这张卡除外（aux.bfgcost实现了除外自身作为代价）。
	e2:SetCost(aux.bfgcost)
	e2:SetCountLimit(1,17888577)
	e2:SetTarget(c17888577.tgtg)
	e2:SetOperation(c17888577.tgop)
	c:RegisterEffect(e2)
end
-- 定义仪式召唤对象过滤器：选择卡号为34072799的“跨音速鸟”作为要仪式召唤的怪兽。
function c17888577.filter(c,e,tp)
	return c:IsCode(34072799)
end
-- ①效果的发动条件判定：检查手牌中是否存在能用当前仪式素材进行仪式召唤的“跨音速鸟”；并设置效果处理时将从手牌特殊召唤1只仪式怪兽。
function c17888577.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得玩家可用的仪式召唤素材组（含手牌、场上可解放的怪兽以及墓地的仪式魔人等）。
		local mg=Duel.GetRitualMaterial(tp)
		-- 检查手牌中是否存在至少1只“跨音速鸟”，使它可以作为仪式怪兽且存在等级合计≥其等级的合法仪式素材组合。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c17888577.filter,e,tp,mg,nil,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：本次效果将进行特殊召唤，预计从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：选择手牌中要仪式召唤的“跨音速鸟”，选择满足等级合计≥其等级的解放素材，解放素材后以仪式召唤方式特殊召唤，并给该怪兽附加等级变为素材合计等级的效果。
function c17888577.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 在效果处理时再次取得玩家可用的仪式素材组。
	local mg=Duel.GetRitualMaterial(tp)
	-- 向玩家发出选择提示，要求选择要特殊召唤的怪兽（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的“跨音速鸟”作为仪式召唤的对象。
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c17888577.filter,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 向玩家发出选择提示，要求选择要解放的怪兽作为仪式素材（“请选择要解放的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材选择的额外检查函数，确保所选素材的等级合计不能超过目标怪兽等级过多（本卡为“Greater”，即合计≥等级即可，但避免多余素材）。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足条件的一组仪式素材，要求等级合计≥目标怪兽等级，且通过合法组合检查。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除之前设置的额外检查函数，避免影响后续其他选择。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local lv=mat:GetSum(Card.GetLevel)
		-- 解放选定的仪式素材（若素材为墓地的仪式魔人等则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续特殊召唤行为被视为另一次效果处理，以正确触发时点（如“仪式召唤成功时”的诱发效果）。
		Duel.BreakEffect()
		-- 以仪式召唤方式将“跨音速鸟”特殊召唤（不检查召唤条件，不检查苏生限制，表侧攻击表示）。若成功则继续处理后续等级变更。
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			-- 对应①效果中的：“这个效果特殊召唤的怪兽的等级变成那次仪式召唤使用的怪兽的等级合计的等级。”
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
		-- 结束本次特殊召唤步骤的连锁处理，确认特殊召唤完成并触发对应时点。
		Duel.SpecialSummonComplete()
	end
end
-- 定义取对象的过滤器：对象必须是表侧表示且为仪式怪兽，并且卡组中存在与它种族或属性相同的仪式怪兽可供选择。
function c17888577.checkfilter(c,tp)
	local att=c:GetAttribute()
	local race=c:GetRace()
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
		-- 检查卡组中是否存在至少1只满足“仪式怪兽、且属性或种族与对象怪兽相同、可送去墓地”的卡。
		and Duel.IsExistingMatchingCard(c17888577.tgfilter,tp,LOCATION_DECK,0,1,nil,att,race)
end
-- 定义卡组内检索/送去墓地的过滤器：选择仪式怪兽，属性或种族与对象相同，且能够被送去墓地。
function c17888577.tgfilter(c,att,race)
	return bit.band(c:GetType(),0x81)==0x81 and (c:IsAttribute(att) or c:IsRace(race)) and c:IsAbleToGrave()
end
-- ②效果的发动条件与取对象处理：选择自己场上1只表侧表示的仪式怪兽作为对象，并设置处理时将卡组中的仪式怪兽送去墓地。
function c17888577.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c17888577.checkfilter(chkc,tp) end
	-- 若在发动时（chk==0），检查自己场上是否存在表侧表示且符合条件的仪式怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c17888577.checkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发出选择提示，要求选择表侧表示的卡作为对象（“请选择表侧表示的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且符合条件的仪式怪兽作为②效果的对象。
	Duel.SelectTarget(tp,c17888577.checkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本次效果将把卡组中的1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：取对象怪兽的属性与种族，从卡组选择1只与对象属性或种族相同的仪式怪兽送去墓地。
function c17888577.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local att=tc:GetAttribute()
		local race=tc:GetRace()
		-- 向玩家发出选择提示，要求选择要送去墓地的卡（“请选择要送去墓地的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足“仪式怪兽且属性或种族与对象相同”的卡。
		local g=Duel.SelectMatchingCard(tp,c17888577.tgfilter,tp,LOCATION_DECK,0,1,1,nil,att,race)
		if g:GetCount()>0 then
			-- 将选择的卡送去墓地（因效果送去墓地）。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
