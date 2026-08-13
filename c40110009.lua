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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，以自己场上1只「半龙女仆」怪兽为对象才能发动。这张卡加入手卡，那只怪兽回到手卡。
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
-- 过滤出不受此效果影响的怪兽，作为可正常使用的融合素材。
function c40110009.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 判定额外卡组的怪兽是否为龙族融合怪兽、能否以此效果进行融合召唤，以及是否满足当前素材条件。
function c40110009.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时的合法性检测：确认存在可用融合素材融合召唤的龙族融合怪兽；若普通素材不够，再检查连锁素材能否提供额外可选素材，并在可发动时设置特殊召唤的操作信息。
function c40110009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，包括手卡·场上的怪兽以及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只符合条件的龙族融合怪兽，能用当前素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c40110009.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（例如「连锁融合」），用于扩展可选的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在普通素材无法融合召唤时，改用连锁素材提供的素材，再次检查额外卡组是否存在可融合召唤的龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(c40110009.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本次效果将进行1只额外卡组怪兽的特殊召唤（融合召唤），供时点与相关卡片的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 实际执行①效果的融合召唤：从可融合召唤的龙族融合怪兽中选择1只，选好融合素材并送墓，然后将其融合召唤；若使用连锁素材则按连锁素材效果处理。
function c40110009.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的融合素材组，并排除不受此效果影响的卡，得到真正可作为融合素材的卡集合。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c40110009.filter1,nil,e)
	-- 从额外卡组中选出所有在当前素材下可以融合召唤的龙族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c40110009.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家适用的连锁素材效果（若有），以便将连锁素材加入可选范围。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材，从额外卡组中再次筛选出可以融合召唤的龙族融合怪兽。
		sg2=Duel.GetMatchingGroup(c40110009.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的龙族融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否可用通常素材融合召唤；若也能用连锁素材且玩家选择使用连锁素材，则走连锁素材路径，否则使用通常素材路径。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择用于这次融合召唤的融合素材（从通常可用素材中选出）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地，送墓原因包含效果、作为融合素材以及融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使后续的融合召唤作为另一次效果处理，避免影响时点判定。
			Duel.BreakEffect()
			-- 将选中的龙族融合怪兽以融合召唤方式特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材，则选择对应的融合素材並交给连锁素材效果来执行融合召唤。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的对象选择条件：表侧表示的「半龙女仆」怪兽，且可以被加入手卡。
function c40110009.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x133) and c:IsAbleToHand()
end
-- ②效果的发动条件和目标选择：这张卡在墓地存在且能加入手卡，并且己方场上有满足条件的「半龙女仆」怪兽可作为对象；同时确认对象卡的合法位置和控制者。
function c40110009.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40110009.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 检查场上是否存在至少1只满足条件的「半龙女仆」表侧怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c40110009.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只己方场上的「半龙女仆」怪兽作为效果对象，并同时将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c40110009.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置操作信息：预计将这张卡和对象怪兽共2张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- ②效果处理：这张卡加入手卡，对象怪兽回到手卡；若这张卡未能加入手卡或对象失去联系，则不处理对应部分。
function c40110009.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本连锁中登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认这张卡仍与此效果相关联且成功送入手卡，同时确认对象怪兽仍与此效果相关联。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)
		and tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
