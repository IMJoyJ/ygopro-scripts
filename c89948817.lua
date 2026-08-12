--ジュラック・ヴォルケーノ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己场上1只恐龙族怪兽破坏，从卡组把1只「朱罗纪」怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，若这个回合对方是已把怪兽的效果4次以上发动则能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。
-- ③：自己场上的「朱罗纪」怪兽被效果破坏的场合，可以作为代替把自己墓地1只恐龙族怪兽除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 将「朱罗纪陨石兽」的卡片密码加入本卡的关联卡片列表中。
	aux.AddCodeList(c,17548456)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己场上1只恐龙族怪兽破坏，从卡组把1只「朱罗纪」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽特殊召唤的场合，若这个回合对方是已把怪兽的效果4次以上发动则能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	-- ③：自己场上的「朱罗纪」怪兽被效果破坏的场合，可以作为代替把自己墓地1只恐龙族怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。①：自己主要阶段才能发动。自己场上1只恐龙族怪兽破坏，从卡组把1只「朱罗纪」怪兽特殊召唤。②：对方把怪兽特殊召唤的场合，若这个回合对方是已把怪兽的效果4次以上发动则能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。③：自己场上的「朱罗纪」怪兽被效果破坏的场合，可以作为代替把自己墓地1只恐龙族怪兽除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop1)
		-- 注册全局环境效果，用于在有连锁发生时记录玩家发动怪兽效果的次数。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(s.checkop2)
		-- 注册全局环境效果，用于在连锁被无效时修正玩家发动怪兽效果的次数。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 连锁发生时的处理函数，若发动的是怪兽效果，则给该玩家注册一个回合内有效的标识效果（Flag）。
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) then
		-- 给发动怪兽效果的玩家注册一个持续到回合结束的标识效果，用于计数。
		Duel.RegisterFlagEffect(re:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 连锁被无效时的处理函数，用于修正因效果发动被无效而多计入的次数。
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if re and re:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER) then
		-- 获取当前玩家已注册的怪兽效果发动次数标识的数量。
		local ct=Duel.GetFlagEffect(re:GetHandlerPlayer(),id) or 0
		-- 重置（清除）该玩家所有的怪兽效果发动次数标识。
		Duel.ResetFlagEffect(re:GetHandlerPlayer(),id)
		if ct>1 then
			local ra=0
			while ra<ct do
				-- 重新注册标识效果，以恢复扣除1次（因无效而扣除）后的正确计数。
				Duel.RegisterFlagEffect(re:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
				ra=ra+1
			end
		end
	end
end
-- 过滤函数：自己场上表侧表示的恐龙族怪兽，且该怪兽离场后能空出至少1个怪兽区域。
function s.dfilter(c,tp)
	-- 检查卡片是否为表侧表示的恐龙族怪兽，且其离场后自己场上有可用的怪兽区域。
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数：卡组中可以特殊召唤的「朱罗纪」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x22) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的靶向/发动准备函数，检查是否存在可破坏的恐龙族怪兽和可特召的「朱罗纪」怪兽，并设置破坏与特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足条件的恐龙族怪兽。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 发动条件检查：自己场上存在可破坏的恐龙族怪兽，且卡组中存在可特殊召唤的「朱罗纪」怪兽。
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：破坏自己场上的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行函数，选择并破坏自己场上1只恐龙族怪兽，若破坏成功则从卡组特殊召唤1只「朱罗纪」怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只满足条件的恐龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 闪烁显示被选择的怪兽。
	Duel.HintSelection(g)
	-- 破坏选中的怪兽，若破坏成功且此时自己场上有可用的怪兽区域，则继续处理。
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只「朱罗纪」怪兽。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数：检查是否为对方玩家特殊召唤的怪兽。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果②的发动条件函数，检查对方是否特殊召唤了怪兽，且对方本回合发动怪兽效果的次数是否在4次以上。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤的怪兽中是否存在对方特殊召唤的怪兽，且对方本回合发动的怪兽效果次数达到4次或以上。
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.GetFlagEffect(1-tp,id)>=4
end
-- 过滤函数：额外卡组中的「朱罗纪陨石兽」，且其能以同调召唤的方式特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsCode(17548456) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组是否有可用于特殊召唤该怪兽的可用区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的靶向/发动准备函数，检查同调素材限制以及额外卡组中是否存在可特召的「朱罗纪陨石兽」，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：检查是否存在必须作为同调素材的限制。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组中是否存在可以特殊召唤的「朱罗纪陨石兽」。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的执行函数，从额外卡组将1只「朱罗纪陨石兽」当作同调召唤特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查同调素材限制，若不满足则直接返回。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「朱罗纪陨石兽」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的怪兽当作同调召唤特殊召唤，若特殊召唤成功则继续处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
-- 代替破坏的过滤函数：自己场上因效果而被破坏（且非代替破坏）的表侧表示「朱罗纪」怪兽。
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x22) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的除外过滤函数：自己墓地可以除外的恐龙族怪兽。
function s.rmfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemove()
end
-- 效果③的代替破坏目标与条件检查函数，若满足条件则询问玩家是否使用代替效果，并执行除外操作。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查自己墓地是否存在可以除外的恐龙族怪兽。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己墓地选择1只恐龙族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的墓地怪兽除外，作为代替破坏的处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- 代替破坏的价值判断函数，用于确定哪些卡片适用此代替破坏效果。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
