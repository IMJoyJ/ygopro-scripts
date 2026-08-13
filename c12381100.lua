--究極竜魔導師
-- 效果：
-- 「青眼究极龙」（或者「青眼」怪兽×3）＋「混沌」仪式怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：对方把效果发动时才能发动（这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次）。那个发动无效并破坏。
-- ②：表侧表示的这张卡因对方从场上离开的场合才能发动。从自己的额外卡组·墓地把1只「青眼」怪兽或「混沌」仪式怪兽特殊召唤。
local s,id,o=GetID()
-- 该函数在卡片初始化时注册所有效果：登记融合素材卡名、设定苏生限制、特殊召唤条件（仅融合召唤）、自定义融合素材规则、①无效并破坏效果、②离场特召效果。
function s.initial_effect(c)
	-- 将「青眼究极龙」的卡号（23995346）加入本卡的融合素材卡名列表，使后续融合素材判定能识别该卡名。
	aux.AddMaterialCodeList(c,23995346)
	c:EnableReviveLimit()
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为“仅限融合召唤”，即禁止用融合召唤以外方式特殊召唤。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- 「青眼究极龙」（或者「青眼」怪兽×3）＋「混沌」仪式怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(s.fcondition)
	e1:SetOperation(s.foperation)
	c:RegisterEffect(e1)
	-- 对方把效果发动时才能发动（这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次）。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效对方怪兽"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 表侧表示的这张卡因对方从场上离开的场合才能发动。从自己的额外卡组·墓地把1只「青眼」怪兽或「混沌」仪式怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特召「青眼」怪兽或者「混沌」仪式怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义融合素材候选条件之一：是「青眼究极龙」，或者是可作为融合素材替代品的卡。
function s.ffilter1(c,fc)
	return c:IsFusionCode(23995346) or c:CheckFusionSubstitute(fc)
end
-- 定义融合素材候选条件之二：属于「青眼」系列（0xdd）的怪兽。
function s.ffilter2(c)
	return c:IsFusionSetCard(0xdd) and c:IsType(TYPE_MONSTER)
end
-- 定义融合素材候选条件之三：属于「混沌」系列（0xcf）且同时是怪兽和仪式怪兽。
function s.ffilter3(c)
	return c:IsFusionSetCard(0xcf) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL)
end
-- 综合判定一张卡能否作为融合素材：必须可作为融合素材，且满足“青眼究极龙/青眼怪兽/混沌仪式怪兽”中至少一个条件。
function s.ffilter(c,fc)
	return c:IsCanBeFusionMaterial(fc) and (s.ffilter1(c,fc) or s.ffilter2(c) or s.ffilter3(c))
end
-- 用于4素材组合的检查：存在一只「混沌」仪式怪兽，并且除它之外还有3只「青眼」系列怪兽。
function s.f2filter3(c,sg)
	return s.ffilter3(c) and sg:IsExists(s.ffilter2,3,c)
end
-- 检查一组素材是否合法：数量必须是2或4；若指定了特定素材则必须包含；排除调弦之魔术师特殊限制；通过强制素材检查和额外区空格检查，并应用其他追加检查。
function s.fcheck(sg,fc,tp,gc,chkf)
	local ct=#sg
	if ct~=2 and ct~=4 then return false end
	if gc and not sg:IsContains(gc) then return false end
	-- 若素材组中存在受“调弦之魔术师”效果影响的怪兽，则不能作为融合素材使用。
	if sg:IsExists(aux.TuneMagicianCheckX,1,nil,sg,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查素材组是否满足所有“必须作为融合素材”的效果限制（如必须包含指定卡）。
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 检查融合召唤后额外怪兽区是否有空格（若chkf允许调用方不检查则跳过）。
	if not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0) then return false end
	-- 若存在全局追加融合条件检查（FCheckAdditional）且素材组不满足该检查，则判定不合法。
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,sg,fc)
		-- 若存在全局追加融合目标检查（FGoalCheckAdditional）且素材组不满足该检查，则判定不合法。
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,sg,fc) then return false end
	if ct==2 then
		-- 2素材组合时，必须是一只「青眼究极龙」（或替代品）和一只「混沌」仪式怪兽，顺序不限。
		return aux.gffcheck(sg,s.ffilter1,fc,s.ffilter3,nil)
	else
		return sg:IsExists(s.f2filter3,1,nil,sg)
	end
end
-- 融合素材条件入口：先从候选素材中筛出可用卡，再检查是否存在2~4张的合法素材组合。
function s.fcondition(e,g,gc,chkf)
	local tp=e:GetHandlerPlayer()
	-- 当没有候选素材组时，只检查是否满足“必须作为融合素材”的全局限制（用于系统预检）。
	if g==nil then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.ffilter,nil,c)
	if gc and not mg:IsContains(gc) then return false end
	return mg:CheckSubGroup(s.fcheck,2,4,c,tp,gc,chkf)
end
-- 融合素材选择操作：筛选可用素材后，从2~4张合法组合中让玩家选择一组，并设为融合素材。
function s.foperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.ffilter,nil,c)
	-- 显示“请选择要作为融合素材的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
	local g=mg:SelectSubGroup(tp,s.fcheck,false,2,4,c,tp,gc,chkf)
	-- 将选中的卡片组设置为本次融合召唤使用的融合素材。
	Duel.SetFusionMaterial(g)
end
-- 定义另一种融合素材检查（可能用于外部特殊规则）：仅当素材恰为2张且由「青眼究极龙」和「混沌」仪式怪兽组成时通过。
function s.ultimate_fusion_check(tp,sg,fc)
	-- 判断2张素材正好满足「青眼究极龙」+「混沌」仪式怪兽的组合（顺序不限）。
	return #sg==2 and aux.gffcheck(sg,Card.IsFusionCode,23995346,s.ffilter3,nil)
end
-- ①效果的发动条件：对方发动效果、本卡未被战斗破坏、该连锁可被无效，且本回合对应魔法/陷阱/怪兽的效果次数尚未使用。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发动方为对方、此卡不是因战斗破坏而处于该状态，且当前连锁可以被无效化。
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		-- 对方发动的是怪兽效果时，还需本回合未使用过对怪兽效果的次数（flag id=id）。
		and ((re:IsActiveType(TYPE_MONSTER) and Duel.GetFlagEffect(tp,id)==0)
		-- 对方发动的是魔法效果时，还需本回合未使用过对魔法效果的次数（flag id=id+o）。
		or (re:IsActiveType(TYPE_SPELL) and Duel.GetFlagEffect(tp,id+o)==0)
		-- 对方发动的是陷阱效果时，还需本回合未使用过对陷阱效果的次数（flag id=id+o*2）。
		or (re:IsActiveType(TYPE_TRAP) and Duel.GetFlagEffect(tp,id+o*2)==0))
end
-- ①效果的目标处理：登记无效/破坏操作信息；按效果类型注册对应次数限制；创建“已使用”提示效果；若对象卡可破坏且仍关联则登记破坏。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 登记本次连锁中将要无效的对象为对方发动的那个效果（用于发动无效类检测）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:IsActiveType(TYPE_MONSTER) then
		-- 对方发动怪兽效果后，注册本回合已使用过对怪兽效果次数的标志，回合结束重置。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))  --"已对怪兽效果把「究极龙魔导师」的效果发动"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 将“已对怪兽效果发动过”的提示效果注册到场上，使玩家可见。
		Duel.RegisterEffect(e1,tp)
	elseif re:IsActiveType(TYPE_SPELL) then
		-- 对方发动魔法效果后，注册本回合已使用过对魔法效果次数的标志，回合结束重置。
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		-- 这个卡名的这个效果在1回合对魔法·陷阱·怪兽的效果每种各能发动1次
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))  --"已对魔法效果把「究极龙魔导师」的效果发动"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
	elseif re:IsActiveType(TYPE_TRAP) then
		-- 对方发动陷阱效果后，注册本回合已使用过对陷阱效果次数的标志，回合结束重置。
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		-- 那个发动无效并破坏。表侧表示的这张卡因对方从场上离开的场合才能发动。从自己的额外卡组·墓地把1只「青眼」怪兽或「混沌」仪式怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,5))  --"已对陷阱效果把「究极龙魔导师」的效果发动"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
	end
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的效果的对象卡可破坏且与效果仍有关联，则登记破坏该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果处理：先无效对方效果的发动；若该效果关联的卡仍可关联，则将其破坏。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 当发动无效成功且被无效效果对应的卡仍与连锁关联时，执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的效果所关联的卡（组）以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡曾经在我方场上表侧表示，因对方的原因从场上离开。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- ②效果可选的特殊召唤对象：是「青眼」怪兽，或是「混沌」仪式怪兽；且可以被特殊召唤，并满足对应区域空位。
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0xdd) or c:IsSetCard(0xcf) and c:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若候选卡在墓地，则要求我方主要怪兽区有空位才能特殊召唤。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若候选卡在额外卡组，则要求我方额外怪兽区或相应额外区域有空位才能特殊召唤。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的目标处理：确认存在可特召对象，并设置从自己额外卡组·墓地特殊召唤1只的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组·墓地是否存在至少1只满足条件的「青眼」怪兽或「混沌」仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记特殊召唤操作信息：从自己额外卡组·墓地特殊召唤1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ②效果处理：从自己额外卡组·墓地选择1只符合条件的怪兽，将其特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的额外卡组·墓地选择1只满足条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
