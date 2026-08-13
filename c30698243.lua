--スカーレッド・ハイパーノヴァ・ドラゴン
-- 效果：
-- 调整4只＋调整以外的同调怪兽1只以上
-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
-- ②：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ③：自己·对方回合1次，可以发动。这张卡以及对方的场上·墓地的卡全部除外。那之后，可以从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册本卡所有效果，包括记录相关卡名「真红莲新星龙」、混合同调召唤手续、苏生限制、特殊召唤条件、攻击力增益、取对象与破坏抗性、③的除外并特殊召唤效果。
function s.initial_effect(c)
	-- 将卡号97489701（真红莲新星龙）登记到这张卡的卡名参考列表中，表示这张卡记载了该卡名，以支持相关规则判定。
	aux.AddCodeList(c,97489701)
	-- 设置混合同调召唤手续：调整以外的同调怪兽1只以上，加上满足s.mfilter的怪兽4~99只（实际为4只调整），并经过s.syncheck验证素材合法性，实现『调整4只＋调整以外的同调怪兽1只以上』的召唤条件。
	aux.AddSynchroMixProcedure(c,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),nil,nil,s.mfilter,4,99,s.syncheck)
	c:EnableReviveLimit()
	-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升自己墓地的调整数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置取对象抗性的判定函数：效果控制者为这张卡的控制者（即不是对方）时，该效果不能以这张卡为对象，从而免疫对方的效果对象指定。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 场上的这张卡不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	-- 设置破坏抗性的判定函数：只有对方的效果才会被此抗性阻挡，这张卡不会被对方的效果破坏。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ③：自己·对方回合1次，可以发动。这张卡以及对方的场上·墓地的卡全部除外。那之后，可以从额外卡组把1只「真红莲新星龙」当作同调召唤作特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetTarget(s.retg)
	e5:SetOperation(s.reop)
	c:RegisterEffect(e5)
	-- 这张卡用以上记的卡为同调素材的同调召唤才能从额外卡组特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(21142671)
	c:RegisterEffect(e6)
end
s.material_type=TYPE_SYNCHRO
-- 特殊召唤条件判定：这张卡只能通过同调召唤方式从额外卡组出场，且不能通过其他效果或手续被特殊召唤。
function s.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO and not se
end
-- 素材候选过滤：作为混合同调素材时，允许‘调整’或‘非调整的同调怪兽’参与，配合后续检查确定最终材料组合。
function s.mfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER) or not c:IsSynchroType(TYPE_TUNER) and c:IsSynchroType(TYPE_SYNCHRO)
end
-- 检查素材组中是否以1只非调整同调怪兽作为‘调整以外的同调怪兽1只以上’，且剩余素材中恰好有4只调整。
function s.mgcheck(c,mg,syncard)
	local rg=mg-c
	if c:IsNotTuner(syncard) and c:IsSynchroType(TYPE_SYNCHRO) then
		return rg:FilterCount(Card.IsTuner,nil,syncard)==4
	else
		return false
	end
end
-- 整体素材合法性检查：素材组中存在至少1组由1只非调整同调怪兽和4只调整构成的合法同调素材组合。
function s.syncheck(g,syncard)
	return g:IsExists(s.mgcheck,1,nil,g,syncard)
end
-- 攻击力上升值计算函数：统计这张卡控制者墓地的调整怪兽数量，每1只上升500攻击力。
function s.atkval(e,c)
	-- 获取控制者墓地的调整怪兽数量并乘以500，作为攻击力的上升数值。
	return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_TUNER)*500
end
-- ③效果的发动条件和对象登记：确认这张卡可以除外，并收集对方场上·墓地的全部可除外卡加上这张卡，登记为除外对象。
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 取得对方场上和墓地中所有可以被除外的卡，作为效果处理时的候选对象组。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	sg:AddCard(c)
	-- 将本次效果要除外的卡组及数量登记到连锁信息中，用于时点提示和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
-- 额外卡组中「真红莲新星龙」的特殊召唤过滤：需为卡号97489701的同调怪兽，能以同调召唤方式特殊召唤，且额外召唤区有空位。
function s.spfilter(c,e,tp)
	return c:IsCode(97489701) and c:IsType(TYPE_SYNCHRO)
		-- 确认该「真红莲新星龙」能够以同调召唤手续特殊召唤，并且场上有足够的区域容纳额外卡组怪兽。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤卡片的上一控制者是否为tp，用于区分除外的卡中原本属于tp的卡（此处作为辅助过滤）。
function s.rmfilter(c,tp)
	return c:GetPreviousControler()==tp
end
-- 效果处理：将这张卡和对方场上·墓地的所有可除外卡全部表侧除外，若实际除外成功且额外卡组存在可特殊召唤的「真红莲新星龙」，则询问是否将其当作同调召唤特殊召唤。
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方墓地的卡组，用于检查王家长眠之谷是否可能无效这次除外效果。
	local ckg=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	-- 若对方墓地中存在王家长眠之谷影响的卡且本次连锁可被无效，则直接终止处理（效果无效）。
	if aux.NecroValleyNegateCheck(ckg) then return end
	-- 重新获取对方场上和墓地中所有可除外的卡作为本次实际除外的对象组。
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if c:IsRelateToChain() and c:IsAbleToRemove() then sg:AddCard(c) end
	-- 将对象组全部表侧除外；只要实际除外了至少1张卡，就继续执行后续特殊召唤处理。
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 取得刚才那次除外操作中实际被除外的卡片组（可能因替换效果与选择对象不同）。
		local og=Duel.GetOperatedGroup()
		if og:GetCount()>0
			-- 检查是否存在‘必须作为同调素材’等限制，确保玩家能够进行同调召唤手续。
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 检查额外卡组中是否存在符合条件的「真红莲新星龙」可供特殊召唤。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			-- 询问玩家是否要将额外卡组的「真红莲新星龙」当作同调召唤作特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤视为独立处理，以避免错失时点。
			Duel.BreakEffect()
			-- 显示选择特殊召唤卡片的提示，要求玩家选择要特殊召唤的「真红莲新星龙」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只满足s.spfilter条件的「真红莲新星龙」作为特殊召唤对象。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				tc:SetMaterial(nil)
				-- 将选择的「真红莲新星龙」以同调召唤方式特殊召唤；成功后由后续CompleteProcedure完成同调召唤手续。
				if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
