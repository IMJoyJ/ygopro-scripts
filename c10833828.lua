--魔神王の禁断契約書
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
-- ③：自己准备阶段发动。自己受到2000伤害。
function c10833828.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只「DDD」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10833828,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c10833828.sptg1)
	e2:SetOperation(c10833828.spop1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。包含用这张卡的①的效果特殊召唤的怪兽的自己的手卡·场上的怪兽作为融合素材，把1只恶魔族融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10833828,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c10833828.sptg2)
	e3:SetOperation(c10833828.spop2)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段发动。自己受到2000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10833828,2))  --"效果伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c10833828.damcon)
	e4:SetTarget(c10833828.damtg)
	e4:SetOperation(c10833828.damop)
	c:RegisterEffect(e4)
end
-- 判定手卡中的怪兽是否为「DDD」字段且能够以表侧守备表示特殊召唤。
function c10833828.spfilter1(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的合法性检查：自己主要怪兽区有空位，且手卡存在满足特殊召唤条件的「DDD」怪兽。
function c10833828.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在1只以上满足特殊召唤条件的「DDD」怪兽。
		and Duel.IsExistingMatchingCard(c10833828.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 向对方玩家提示发动了此效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：从手卡选1只「DDD」怪兽守备表示特殊召唤，并对其附加效果无效化状态，同时标记该怪兽与本次①效果关联。
function c10833828.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认主要怪兽区有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的「DDD」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c10833828.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧守备表示特殊召唤，成功则继续赋予无效化效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(10833828,RESET_EVENT+RESETS_STANDARD,0,1,c:GetFieldID())
	end
	-- 完成特殊召唤处理，触发特殊召唤成功的时点。
	Duel.SpecialSummonComplete()
end
-- 过滤出不受本效果影响的怪兽（即不能作为融合素材的怪兽排除）。
function c10833828.spfilter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中满足恶魔族、融合怪兽、可被融合召唤且符合融合素材条件的怪兽。
function c10833828.spfilter3(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 生成融合素材额外检查：要求所选素材中必须包含带有本次①效果特殊召唤标记的怪兽。
function c10833828.fcheck1(fid)
	return	function(tp,sg,fc)
				return sg:IsExists(c10833828.fcheck2,1,nil,fid)
			end
end
-- 判断怪兽是否带有本次①效果特殊召唤时赋予的标记（字段ID）。
function c10833828.fcheck2(c,fid)
	for _,flag in ipairs({c:GetFlagEffectLabel(10833828)}) do
		if flag==fid then return true end
	end
	return false
end
-- ②效果的发动合法性检查：能否从额外卡组选出1只恶魔族融合怪兽，并以包含①效果特殊召唤的怪兽在内的自己手卡·场上的怪兽作为融合素材进行融合召唤。
function c10833828.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材（手卡·场上的怪兽以及额外融合素材）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 临时设定融合素材必须包含①效果特殊召唤的怪兽标记的额外检查条件。
		aux.FCheckAdditional=c10833828.fcheck1(e:GetHandler():GetFieldID())
		-- 检查额外卡组中是否存在可使用的恶魔族融合怪兽（基于当前融合素材）。
		local res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取自己受到的连锁素材效果（用于处理额外融合素材）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若通常素材无法融合，则使用连锁素材提供的新素材组再次检查是否存在可融合的恶魔族怪兽。
				res=Duel.IsExistingMatchingCard(c10833828.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 清除临时设定的额外融合素材检查条件。
		aux.FCheckAdditional=nil
		return res
	end
	-- 设置本次效果处理的信息：从额外卡组特殊召唤1只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示发动了此效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果处理：选择1只恶魔族融合怪兽，选择包含①效果特殊召唤怪兽的融合素材送去墓地，进行融合召唤；若使用连锁素材则按连锁素材效果处理。
function c10833828.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取自己可用的融合素材，并排除不受本效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c10833828.spfilter2,nil,e)
	-- 临时设定融合素材必须包含①效果特殊召唤的怪兽标记的额外检查条件。
	aux.FCheckAdditional=c10833828.fcheck1(c:GetFieldID())
	-- 筛选出所有可用当前素材融合召唤的恶魔族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取自己受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的新素材组，筛选出可融合召唤的恶魔族融合怪兽。
		sg2=Duel.GetMatchingGroup(c10833828.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出“请选择要特殊召唤的卡”的选择提示框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果选择的融合怪兽既可用通常素材又可用连锁素材，则询问玩家是否使用连锁素材，以决定融合处理方式。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择该融合怪兽所需的通常融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以融合素材理由送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合特殊召唤与素材送墓分开处理，以避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的融合怪兽特殊召唤到自己场上（表侧表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除临时设定的额外融合素材检查条件。
	aux.FCheckAdditional=nil
end
-- ③效果的发动条件：自己的准备阶段（当前回合玩家为自己）。
function c10833828.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- ③效果的发动时点（必发）目标设定：将伤害对象设为自己的玩家，伤害数值设为2000，并登记伤害操作信息。
function c10833828.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设为2000。
	Duel.SetTargetParam(2000)
	-- 登记本次效果将对目标玩家造成2000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,2000)
end
-- ③效果处理：从连锁信息中取出目标玩家和伤害数值，给予其2000点效果伤害。
function c10833828.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中设定的目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予目标玩家2000点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
