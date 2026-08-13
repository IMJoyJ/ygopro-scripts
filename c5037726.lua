--光霊術－「聖」
-- 效果：
-- ①：把自己场上1只光属性怪兽解放，以除外的1只自己或者对方的怪兽为对象才能发动。对方可以从手卡把1张陷阱卡给人观看让这个效果无效。没给观看的场合，作为对象的怪兽在自己场上特殊召唤。
function c5037726.initial_effect(c)
	-- ①：把自己场上1只光属性怪兽解放，以除外的1只自己或者对方的怪兽为对象才能发动。对方可以从手卡把1张陷阱卡给人观看让这个效果无效。没给观看的场合，作为对象的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c5037726.cost)
	e1:SetTarget(c5037726.target)
	e1:SetOperation(c5037726.operation)
	c:RegisterEffect(e1)
end
-- 解放素材的过滤条件：必须是光属性怪兽；若主怪兽区没有空位则只能选自己场上主要怪兽区（序列0-4）的怪兽，且对方怪兽必须表侧表示。
function c5037726.rfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价处理：先标记本次发动需要额外检查主怪兽区空位，计算可用空格；合法检查时确认存在可解放的光属性怪兽且解放后仍有空位；实际发动时选择1只光属性怪兽解放作为代价。
function c5037726.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取自己场上主要怪兽区可用空格数，用于判断解放后能否空出特殊召唤位置。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- cost合法性检查：要求解放后仍有至少1个主怪兽区空格，并且场上存在满足条件的光属性怪兽可作为解放素材。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c5037726.rfilter,1,nil,ft,tp) end
	-- 选择1只满足条件的光属性怪兽作为解放素材。
	local g=Duel.SelectReleaseGroup(tp,c5037726.rfilter,1,1,nil,ft,tp)
	-- 将选择的怪兽解放，作为发动这张卡的代价。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤对象的过滤函数：必须是表侧表示，且能被当前效果特殊召唤（不检查召唤条件、苏生限制）。
function c5037726.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择处理：若指定对象则验证是除外区表侧可特召怪兽；发动时根据cost标记判断是否需要额外检查主怪兽区空格；随后提示玩家选择1只除外的表侧可特召怪兽作为对象，并设置操作信息。
function c5037726.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c5037726.filter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查除外区是否存在至少1只满足条件的表侧表示可特殊召唤怪兽作为对象。
			return Duel.IsExistingTarget(c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
		else
			-- 检查自己场上是否有可用的主怪兽区空格，用于后续特殊召唤。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 并且检查除外区是否存在满足条件的可特殊召唤对象，确保有空格且有对象才能发动。
				and Duel.IsExistingTarget(c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 向发动玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方除外区选择1只满足条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c5037726.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置本连锁的操作信息：包含特殊召唤分类，对象为选择的那只怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 筛选对方手卡中非公开状态的陷阱卡，这些卡可以作为“给人观看”来让本效果无效的候选。
function c5037726.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_TRAP)
end
-- 效果处理：若当前连锁效果可被无效，则询问对方是否展示手卡陷阱卡；若展示则确认并洗牌且无效本效果；否则将对象怪兽特殊召唤到自己场上。
function c5037726.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁的效果是否能够被无效（对方是否能通过展示陷阱卡使本效果无效）。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手卡中所有非公开状态的陷阱卡，作为可展示的候选组。
		local g=Duel.GetMatchingGroup(c5037726.cfilter,tp,0,LOCATION_HAND,nil)
		-- 向对方玩家发出“是否把1张陷阱卡给对方观看？”的选择提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(5037726,0))  --"是否把1张陷阱卡给对方观看？"
		if g:GetCount()>0 then
			-- 当对方手卡有可展示的陷阱卡时，弹出“是/否”选项，选择是则sel=0。
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 当对方手卡没有可展示的陷阱卡时，只有“否”选项，加1使sel=1，强制选择否。
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 若对方选择展示，提示对方选择要给人观看的那张卡。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的陷阱卡给发动方玩家确认。
			Duel.ConfirmCards(tp,sg)
			-- 确认后洗切对方手卡，避免手卡顺序被额外获知。
			Duel.ShuffleHand(1-tp)
			-- 使当前连锁的效果无效，即本卡效果被对方展示陷阱卡而无效。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 取得本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动者自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
