--ジャンク・ウォリアー・エクストリーム
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把2星以下的怪兽尽可能特殊召唤，这个回合，那些怪兽的效果不能发动。这个效果的发动后，直到回合结束时自己只能有1次特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡除外才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化函数：为卡片声明素材「废品同调士」，设置同调召唤手续与苏生限制，注册①墓地特殊召唤效果和②战斗破坏除外后从额外卡组同调召唤「废品」同调怪兽的效果。
function s.initial_effect(c)
	-- 将「废品同调士」(63977008)加入此卡的同调素材卡名列表，使此卡在规则上视为以「废品同调士」为素材。
	aux.AddMaterialCodeList(c,63977008)
	-- 设置同调召唤手续：调整怪兽必须满足s.tfilter（即「废品同调士」或拥有指定替代效果的卡），调整以外怪兽为任意非调整怪兽，合计至少1只。
	aux.AddSynchroProcedure(c,s.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把2星以下的怪兽尽可能特殊召唤，这个回合，那些怪兽的效果不能发动。这个效果的发动后，直到回合结束时自己只能有1次特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时，把这张卡除外才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：此卡与对方怪兽进行战斗并将对方怪兽破坏（使用通用战斗破坏判定aux.bdocon）。
	e2:SetCondition(aux.bdocon)
	-- 设置②效果的发动代价：将此卡自身除外（使用通用除外代价函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.material_setcode=0x1017
-- 定义同调素材中调整的筛选条件：可以是「废品同调士」(63977008)，也可以是带有效果20932152（可视为「废品同调士」素材的卡）的卡。
function s.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 设置①效果的发动条件：此卡以同调召唤方式成功特殊召唤。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义墓地特殊召唤的怪兽筛选条件：等级2以下且可以被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动合法性检查：我方主要怪兽区有空位，且墓地存在至少1只满足条件的2星以下怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足spfilter（2星以下且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：此效果预计从墓地特殊召唤1只怪兽，用于后续时点/效果互动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：获取可用怪兽区空格数，获取墓地中符合条件的怪兽组；若有空格，则根据空格数选择或全部特殊召唤；被特殊召唤的怪兽本回合效果无效化；随后给自己附加本回合只能再进行1次特殊召唤的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方主要怪兽区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取墓地中满足条件且不受「王家长眠之谷」影响的2星以下怪兽组成的集合。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local g=nil
		if tg:GetCount()>ft then
			-- 弹出选择提示，让玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=tg:Select(tp,ft,ft,nil)
		else
			g=tg
		end
		if g:GetCount()>0 then
			-- 遍历所有选出的要特殊召唤的怪兽。
			for tc in aux.Next(g) do
				-- 将当前怪兽以表侧表示特殊召唤（作为连续特殊召唤处理的一步）。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 这个回合，那些怪兽的效果不能发动。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			-- 完成这一组连续特殊召唤处理，确定特殊召唤成功。
			Duel.SpecialSummonComplete()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己只能有1次特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetLabel(s.getsummoncount(tp))
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤”的限制效果注册到场上，作用于我方玩家。
	Duel.RegisterEffect(e2,tp)
	-- 这个效果的发动后，直到回合结束时自己只能有1次特殊召唤；从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetLabel(s.getsummoncount(tp))
	e3:SetValue(s.countval)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册e3效果：记录并限制我方本回合剩余可特殊召唤次数（配合EFFECT_LEFT_SPSUMMON_COUNT）。
	Duel.RegisterEffect(e3,tp)
end
-- 定义辅助函数：获取指定玩家本回合已经进行过的特殊召唤次数。
function s.getsummoncount(tp)
	-- 调用Duel.GetActivityCount获取当前玩家的特殊召唤次数。
	return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
-- 定义限制条件：当本回合已进行的特殊召唤次数超过发动①效果时记录的次数时，禁止再进行特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return s.getsummoncount(sump)>e:GetLabel()
end
-- 定义剩余特殊召唤次数的取值：若当前特殊召唤次数已超过记录值则剩余0次，否则剩余1次。
function s.countval(e,re,tp)
	if s.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
-- 定义②效果选择额外卡组「废品」同调怪兽的筛选条件：必须是「废品」字段的同调怪兽，且可以当作同调召唤进行特殊召唤，并且需满足额外卡组出场空格要求。
function s.spfilter2(c,e,tp,ec)
	return c:IsSetCard(0x43) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 额外检查：在考虑当前卡离场后，额外卡组的这张同调怪兽是否有可用的特殊召唤区域。
		and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
end
-- ②效果的发动合法性检查：不存在“必须作为同调素材”的限制卡，且额外卡组存在至少1只满足s.spfilter2的「废品」同调怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查全场是否存在受“必须作为同调素材”效果影响的卡，若有则不能以同调召唤方式从额外卡组特殊召唤。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在至少1只满足条件的「废品」同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：此效果预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：再次确认没有必须素材限制，从额外卡组选择1只「废品」同调怪兽，清除其素材记录，以同调召唤方式特殊召唤并完成同调召唤手续。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若存在“必须作为同调素材”的限制，则效果处理中止。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的「废品」同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「废品」同调怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤方式将选择的怪兽特殊召唤到场上；若成功则完成同调召唤手续。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
