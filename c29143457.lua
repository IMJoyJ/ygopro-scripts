--炎舞－「隠元」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从自己的手卡·场上把兽战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽加入手卡。
function c29143457.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张；①：作为这张卡的发动时的效果处理，以下效果可以适用。●从自己的手卡·场上把兽战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29143457+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c29143457.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合，以自己墓地1只「炎星」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29143457,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,29143458)
	e2:SetCondition(c29143457.thcon)
	e2:SetTarget(c29143457.thtg)
	e2:SetOperation(c29143457.thop)
	c:RegisterEffect(e2)
end
-- 过滤出不受该效果免疫的卡，确保这些卡可作为融合素材使用。
function c29143457.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 从额外卡组筛选满足条件的兽战士族融合怪兽：必须是兽战士族、能以当前素材进行融合召唤，并且能被此效果以融合召唤方式特殊召唤。
function c29143457.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_BEASTWARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的处理：获取我方手卡·场上及额外融合素材，筛选可融合召唤的兽战士族融合怪兽；若玩家确认融合召唤，则选择1只融合怪兽，选用通常素材或连锁素材将其素材送去墓地，并将该融合怪兽以融合召唤方式特殊召唤。
function c29143457.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取我方可用于融合召唤的素材（手卡·场上怪兽及受额外融合素材效果影响的卡），并排除对此效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29143457.filter1,nil,e)
	-- 从额外卡组筛选出能用这些素材进行融合召唤的兽战士族融合怪兽，作为候选特殊召唤对象。
	local sg1=Duel.GetMatchingGroup(c29143457.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家当前适用的“连锁素材”类效果（若有），用于扩展融合素材的来源。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 根据连锁素材效果提供的素材和条件，从额外卡组筛选出可融合召唤的兽战士族融合怪兽，作为第二组候选。
		sg2=Duel.GetMatchingGroup(c29143457.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	-- 若存在至少1只可融合召唤的候选融合怪兽，且玩家选择发动融合召唤效果，则继续进行处理。
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(29143457,1)) then  --"是否融合召唤？"
		-- 中断当前效果处理，使后续的融合召唤动作作为独立处理，避免造成错误的时点。
		Duel.BreakEffect()
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽：若它能使用通常素材融合，且不使用连锁素材（或玩家拒绝使用连锁素材），则按通常融合素材处理；否则按连锁素材效果处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常融合素材中选择一组融合召唤需要的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以“效果+素材+融合”的原因送去墓地，作为融合召唤的素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 再次中断效果处理，使素材送墓与融合怪兽的特殊召唤不在同一时点处理。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以表侧表示、融合召唤方式特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从连锁素材提供的素材中选择融合召唤需要的素材组。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的发动条件：这张卡是从魔法与陷阱区域表侧表示被送去墓地的场合（此前位置为魔陷区且表侧表示）才能发动。
function c29143457.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②效果的对象过滤：自己墓地的「炎星」怪兽，且能够加入手卡。
function c29143457.thfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果发动时的目标选择：从自己墓地选择1只符合条件的「炎星」怪兽作为对象，并设定处理信息为将其加入手卡。
function c29143457.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29143457.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只可加入手卡的「炎星」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c29143457.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的「炎星」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c29143457.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定本次效果处理的信息为将对象卡加入手卡（CATEGORY_TOHAND），用于后续时点及效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若作为对象的「炎星」怪兽仍与此效果关联，则将其加入持有者手卡。
function c29143457.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，理由为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
