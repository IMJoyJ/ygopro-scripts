--ミラクルシンクロフュージョン
-- 效果：
-- ①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把以同调怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
function c36484016.initial_effect(c)
	-- ①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把以同调怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36484016.target)
	e1:SetOperation(c36484016.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36484016,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36484016.drcon)
	e2:SetTarget(c36484016.drtg)
	e2:SetOperation(c36484016.drop)
	c:RegisterEffect(e2)
end
-- 过滤出场上存在且可以被除去的卡片，作为效果①融合素材的候选之一。
function c36484016.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤出场上存在、可以被除外且不免疫当前效果的怪兽，作为效果处理时可实际使用的融合素材候选。
function c36484016.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中的融合怪兽：必须是融合怪兽、其融合素材记述包含同调怪兽、满足追加素材条件（如有），并且能够以融合召唤方式被当前效果特殊召唤；不满足则返回false。
function c36484016.filter2(c,e,tp,m,f,chkf)
	-- 判断额外卡组中的候选卡是否为融合怪兽、其融合素材中是否记载有同调怪兽，并通过追加素材条件f（若存在）的检查。
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListType(c,TYPE_SYNCHRO) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置附加的融合素材合法性检查函数，优先使用融合怪兽自身的synchro_fusion_check，否则使用本卡专用的fcheck（要求素材组中存在至少1只同调怪兽）。
	aux.FCheckAdditional=c.synchro_fusion_check or c36484016.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除附加的融合素材检查函数，避免影响其他卡片的融合处理。
	aux.FCheckAdditional=nil
	return res
end
-- 过滤出墓地中可作为融合素材且可以被除去的怪兽，作为效果①从墓地选择的融合素材候选。
function c36484016.filter4(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 附加素材检查函数：确认所选的融合素材组中至少存在1只融合种类为同调怪兽的怪兽，以满足“以同调怪兽为融合素材”的要求。
function c36484016.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionType,1,nil,TYPE_SYNCHRO)
end
-- 效果①的发动判定与操作信息设置：检查能否从自己场上·墓地凑齐可作为融合素材的怪兽，并在额外卡组中存在以同调怪兽为素材且能满足融合召唤条件的融合怪兽；也考虑连锁素材效果提供的素材；可以发动时登记特殊召唤与除外的操作信息。
function c36484016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材（包括手卡·场上及额外融合素材效果影响的卡），并过滤出场上存在且可除去的怪兽，作为普通素材候选。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c36484016.filter0,nil)
		-- 获取自己墓地中可作为融合素材且可除去的怪兽，并入素材候选组。
		local mg2=Duel.GetMatchingGroup(c36484016.filter4,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在至少1只满足条件的融合怪兽（以当前普通素材组mg1可融合召唤，且素材包含同调怪兽），用于判定效果是否可发动。
		local res=Duel.IsExistingMatchingCard(c36484016.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果，用于追加融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果提供的素材组mg3下，检查额外卡组中是否仍存在可融合召唤且满足素材条件的融合怪兽，从而决定效果能否发动。
				res=Duel.IsExistingMatchingCard(c36484016.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次连锁的特殊召唤操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 登记本次连锁的除外操作信息：除外区域为自己场上或墓地，预计除外1组融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果①的融合召唤处理：选择融合怪兽，从场上/墓地（或连锁素材）选择并除外融合素材，随后将融合怪兽以融合召唤方式特殊召唤；处理过程中设置附加素材检查，最后完成融合召唤手续并清理附加检查。
function c36484016.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 在效果处理阶段重新获取可用融合素材，过滤出场上存在、可除外且不免疫此效果的怪兽，作为实际可选择素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c36484016.filter1,nil,e)
	-- 获取自己墓地中可作为融合素材且可除去的怪兽，并入本次处理的素材候选。
	local mg2=Duel.GetMatchingGroup(c36484016.filter4,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 根据普通素材组mg1，筛出额外卡组中所有满足融合召唤条件（素材含同调怪兽）的融合怪兽，作为可特殊召唤候选组。
	local sg1=Duel.GetMatchingGroup(c36484016.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果，若有则准备使用其提供的素材和操作。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 根据连锁素材效果提供的素材组mg3，筛出额外卡组中满足融合召唤条件的融合怪兽，作为另一组特殊召唤候选。
		sg2=Duel.GetMatchingGroup(c36484016.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从额外卡组选择要特殊召唤的融合怪兽，显示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设置附加素材检查：要求最终素材组中至少包含1只同调怪兽，优先使用所选融合怪兽自身的synchro_fusion_check，否则使用本效果的fcheck。
		aux.FCheckAdditional=tc.synchro_fusion_check or c36484016.fcheck
		-- 判断是否走常规融合召唤流程：所选融合怪兽在普通候选组sg1中，且（不存在连锁素材候选或玩家未选择使用连锁素材效果）时，执行普通素材选择；否则执行连锁素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组mg1中选择该融合怪兽所需的融合素材，返回素材组mat1。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材mat1以表侧表示除外，原因为效果、素材和融合，完成融合素材的除外。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤与之前的除外处理视为不同时处理，以避免错过时点。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤方式特殊召唤到自己的场上，表示形式为表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家在连锁素材效果提供的素材组mg3中，选择该融合怪兽所需的融合素材，返回素材组mat2。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除附加的融合素材检查函数，防止影响后续其他融合相关处理。
	aux.FCheckAdditional=nil
end
-- 效果②的发动条件：这张卡在自己场上里侧表示存在期间，被对方玩家的效果破坏并送去墓地，且此卡之前由自己控制。
function c36484016.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②发动时的目标处理：检查阶段直接返回true；随后设置抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c36484016.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己，即抽卡玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记本次连锁的抽卡操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的抽卡处理：从连锁信息中取得抽卡玩家和抽卡张数，让该玩家以效果原因抽相应数量的卡。
function c36484016.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家p（抽卡玩家）和对象参数d（抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
