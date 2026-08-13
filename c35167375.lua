--サプライズ・フュージョン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽变成宣言的种族·属性。那之后，可以把包含那只怪兽的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只融合怪兽解放，把持有和那个等级相同等级的2只「惊喜衍生物」（魔法师族·暗·攻/守0）在自己场上特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数：为该卡注册两个效果——①的发动效果（改变对象种族·属性并可融合召唤）和②的墓地起动效果（除外自身、解放融合怪兽特招2只衍生物），并对②效果设置1回合1次的次数限制。
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象，宣言种族和属性各1个才能发动。那只怪兽变成宣言的种族·属性。那之后，可以把包含那只怪兽的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。自己场上1只融合怪兽解放，把持有和那个等级相同等级的2只「惊喜衍生物」（魔法师族·暗·攻/守0）在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价：从墓地除外这张卡（aux.bfgcost为封装好的除外自身作为cost的函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象过滤器：怪兽必须表侧表示，且其当前种族或属性至少有一项不是全种族/全属性，即存在可被宣言改变的余地。
function s.rafilter(c)
	return c:IsFaceup() and ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0)
end
-- ①效果的发动条件与目标处理：选择自己场上1只表侧表示怪兽为对象；然后根据对象当前种族/属性情况，让玩家宣言1个种族和1个属性（若某项已无变化空间则必须宣言与当前不同的值），最后将宣言结果存入效果标签，供处理时使用。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and s.rafilter(chkc) end
	-- 在发动合法性检查阶段，确认自己场上存在至少1只满足s.rafilter条件的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.rafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示『请选择表侧表示的卡』的提示，引导玩家选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上的表侧表示怪兽中选择1张作为效果对象并登记，返回该对象卡。
	local tc=Duel.SelectTarget(tp,s.rafilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local race,att
	-- 显示『请选择要宣言的种族』的提示，准备让玩家宣言种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	if ATTRIBUTE_ALL&~tc:GetAttribute()==0 then
		-- 当对象怪兽的属性已覆盖全部属性（没有可再改变的属性）时，宣言的种族必须与其当前种族不同，故从全种族中排除当前种族后由玩家宣言1个种族。
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~tc:GetRace())
	else
		-- 当对象怪兽的属性仍有可改变空间时，玩家可以从全种族中任选1个种族宣言。
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	-- 显示『请选择要宣言的属性』的提示，准备让玩家宣言属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	if RACE_ALL&~tc:GetRace()==0 or race==tc:GetRace() then
		-- 当对象怪兽的种族已覆盖全部种族，或宣言的种族与当前种族相同时，宣言的属性必须与其当前属性不同，故从全属性中排除当前属性后由玩家宣言1个属性。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~tc:GetAttribute())
	else
		-- 当对象怪兽的种族仍有可改变空间且宣言的种族与当前种族不同时，玩家可以从全属性中任选1个属性宣言。
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
-- 融合素材过滤器：要求卡片位于场上且不免疫当前效果，确保其可作为融合素材被使用。
function s.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤器：筛选额外卡组中能被当前效果特殊召唤、满足融合召唤条件、且能用指定素材组（包含对象怪兽）进行融合召唤的融合怪兽。
function s.filter2(c,e,tp,m,ec,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,ec,chkf)
end
-- ①效果处理：将对象怪兽的种族和属性改为宣言值；若对象不在场上、是对方怪兽或种族属性未实际改变，则结束处理；否则询问玩家是否进行融合；若选择是，则获取可用融合素材（含连锁素材），让玩家选择融合怪兽和包含对象怪兽的素材，将素材送墓后完成融合召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,att=e:GetLabel()
	-- 获取①效果选择的己方场上表侧表示的对象怪兽。
	local ec=Duel.GetFirstTarget()
	if ec:IsRelateToChain() and ec:IsFaceup() and ec:IsType(TYPE_MONSTER) then
		local cres=ec:GetRace()~=race or ec:GetAttribute()~=att
		-- 那只怪兽变成宣言的种族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 那只怪兽变成宣言的属性。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(att)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
		-- 刷新场地信息，使刚变更的种族/属性立即反映到后续的融合素材检查与怪兽状态判断中。
		Duel.AdjustAll()
		if ec:IsControler(1-tp) or not cres then return false end
		local chkf=tp
		-- 获取当前玩家可用的全部融合素材组（手卡·场上及受额外融合素材效果影响的卡），并排除不受本效果影响的卡，得到普通素材组mg1。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在至少1只融合怪兽，能用普通素材组mg1且包含对象怪兽ec作为素材进行融合召唤，并可被特殊召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,ec,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（Duel.GetChainMaterial），用于在普通素材不足时使用连锁素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若普通素材无法融合，则使用连锁素材效果提供的素材组mg2重新检查是否存在可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,ec,mf,chkf)
			end
		end
		-- 当存在可融合召唤的候选时，询问玩家是否进行融合；玩家选择『是』才继续后续融合处理。
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行融合？"
			chkf=tp
			-- 玩家确认融合后，再次获取并过滤当前可用的普通融合素材组，确保素材状态最新有效。
			mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
			-- 获取额外卡组中所有能用普通素材组mg1进行融合召唤的融合怪兽候选组sg1。
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,ec,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 再次获取连锁素材效果（若存在），用于扩展融合素材选择。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取额外卡组中所有能用连锁素材效果提供的素材组mg2进行融合召唤的融合怪兽候选组sg2。
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,ec,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 显示『请选择要特殊召唤的卡』的提示，让玩家从合并后的融合怪兽候选中选择1只。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判断所选融合怪兽的召唤方式：若它在普通素材候选sg1中，并且（没有连锁素材候选、或不在连锁素材候选sg2中、或玩家选择不使用连锁素材效果），则使用普通素材融合；否则使用连锁素材效果融合。
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 让玩家从普通素材组中选择一组融合素材，其中必须包含对象怪兽ec，且满足所选融合怪兽的素材要求。
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,ec,chkf)
					tc:SetMaterial(mat1)
					-- 将选定的融合素材送入墓地，原因为效果、融合素材。
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断当前效果处理，使接下来的融合召唤作为独立的特殊召唤时点处理，避免错过时点。
					Duel.BreakEffect()
					-- 将选择的融合怪兽以融合召唤方式表侧表示特殊召唤到己方场上。
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 让玩家从连锁素材效果提供的素材组中选择一组融合素材，其中必须包含对象怪兽ec，然后交给连锁素材效果执行融合处理。
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,ec,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
-- ②效果的解放对象过滤器：选择自己场上可被效果解放的融合怪兽；当chk为true时，还额外检查有足够怪兽区空格、己方不受【青眼精灵龙】效果影响且能够特殊召唤衍生物，以确保解放后能成功特招2只衍生物。
function s.cfilter(c,tp,chk)
	return c:IsType(TYPE_FUSION) and c:IsReleasableByEffect() and (not chk
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (Duel.GetMZoneCount(tp,c)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查玩家能否特殊召唤卡号为id+o（即「惊喜衍生物」）的衍生物，其等级与解放怪兽相同，种族为魔法师族、属性为暗、攻击力/守备力为0。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,c:GetLevel(),RACE_SPELLCASTER,ATTRIBUTE_DARK)))
end
-- ②效果的发动条件检查和操作信息设定：取得可解放怪兽组，若存在满足条件的融合怪兽则允许发动；同时设置本次效果将解放1只怪兽、特殊召唤2只衍生物（即2只怪兽）的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上可用于效果解放的怪兽组（不包含手卡）。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	if chk==0 then return rg:IsExists(s.cfilter,1,nil,tp,true) end
	-- 设置操作信息：本次效果预计解放1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置操作信息：本次效果预计特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果预计特殊召唤2只怪兽（即衍生物）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果处理：从可解放怪兽组中选择1只融合怪兽并解放；若解放成功且己方怪兽区至少还有2个空格、不受【青眼精灵龙】效果影响、且能特殊召唤衍生物，则生成2只与解放怪兽等级相同的「惊喜衍生物」并同时特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用于效果解放的怪兽组。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
	-- 显示『请选择要解放的卡』的提示，让玩家选择要解放的融合怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local srg=nil
	-- 预先检查当前是否已存在满足额外条件（包括能成功特招衍生物）的解放候选，作为后续选择过滤器的chk参数，避免选中后因场地或限制无法特招衍生物。
	local chk=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp,true)
	srg=rg:FilterSelect(tp,s.cfilter,1,1,nil,tp,chk)
	if srg and srg:GetCount()>0 then
		local rc=srg:GetFirst()
		local level=rc:GetLevel()
		-- 解放所选的融合怪兽；若实际解放成功（返回值>0），才继续执行后续的衍生物特殊召唤。
		if Duel.Release(rc,REASON_EFFECT)>0
			-- 确认自己场上至少还有2个可用的主要怪兽区，用于特殊召唤2只衍生物。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 确认玩家能够特殊召唤等级与解放怪兽相同、卡号为id+o、魔法师族·暗属性、攻/守0的衍生物。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,level,RACE_SPELLCASTER,ATTRIBUTE_DARK) then
			for i=1,2 do
				-- 生成1只「惊喜衍生物」Token。
				local token=Duel.CreateToken(tp,id+o)
				-- 把持有和那个等级相同等级的2只「惊喜衍生物」（魔法师族·暗·攻/守0）在自己场上特殊召唤。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
				e1:SetValue(level)
				token:RegisterEffect(e1,true)
				-- 将衍生物以特殊召唤步骤加入处理队列（暂时不完成召唤），以便两只衍生物作为同一次特殊召唤同时处理。
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			end
			-- 完成所有衍生物的特殊召唤流程，两只衍生物同时特殊召唤成功。
			Duel.SpecialSummonComplete()
		end
	end
end
