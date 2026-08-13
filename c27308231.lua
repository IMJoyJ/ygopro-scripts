--K9－LC拘束解除
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「K9」超量怪兽或者5阶超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册该卡的①和②两个效果，并注册一个全局监测效果监听伤害计算后，用于记录本回合有K9怪兽进行过战斗的控制者，为②发动条件提供依据。
function s.initial_effect(c)
	-- ①：以自己场上1只「K9」超量怪兽或者5阶超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 全局战斗监测及①/②效果处理函数：①：以自己场上1只「K9」超量怪兽或者5阶超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		-- 将该全局监测效果注册为全场效果（1号玩家侧），持续监测所有怪兽的伤害计算后事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 伤害计算后，当攻击方或被攻击方为K9怪兽时，为其控制者注册flag，标记该控制者本回合有K9怪兽进行过战斗。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽（若攻击对象不存在则为nil）。
	local at=Duel.GetAttackTarget()
	-- 获取发动攻击的怪兽。
	local ar=Duel.GetAttacker()
	if at and at:IsSetCard(0x1cb) then
		-- 若被攻击的怪兽是K9，则给其控制者注册一个结束阶段重置的flag，表示其本回合有K9怪兽进行过战斗。
		Duel.RegisterFlagEffect(at:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
	if ar and ar:IsSetCard(0x1cb) then
		-- 若攻击怪兽是K9，则给其控制者注册同样的flag。
		Duel.RegisterFlagEffect(ar:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 选择对象的过滤函数：对象必须是表侧表示的K9或5阶超量怪兽，且能作为超量素材，并且额外卡组存在可特殊召唤的卡名不同的K9超量怪兽。
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and (c:IsSetCard(0x1cb) or c:IsRank(5))
		-- 检查对象怪兽是否没有受到“必须作为超量素材”效果的限制，确保其可以作为超量召唤的素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只符合条件的K9超量怪兽，用于后续重叠特殊召唤。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
end
-- 额外卡组候选卡的过滤函数：须为K9超量怪兽（与对象卡名不同），对象可作为其超量素材，且能以超量召唤方式特殊召唤，并有可用额外怪兽区/主要怪兽区空格。
function s.filter2(c,e,tp,mc,code)
	return c:IsSetCard(0x1cb) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 确认候选怪兽能够以超量召唤方式特殊召唤，且从额外卡组特殊召唤后仍有可用区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果发动时的目标选择与操作信息设置：选择1只自己场上的K9或5阶超量怪兽，并预告将进行1次超量特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 发动时点检查：确认场上存在满足条件的对象可供选择。
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 向玩家发出选择对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择满足条件的对象，并将其登记为当前效果的对象。
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果处理将从额外卡组特殊召唤1只怪兽（数量1，位置额外卡组），供相关卡牌（如星尘龙/王家长眠之谷）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时取出对象，并检查对象是否仍可成为素材、是否表侧、是否仍与连锁关联、控制权是否仍属于自己、是否不受此效果影响，若有任一不满足则直接结束。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象已不再满足“必须作为超量素材”的合法条件，则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的额外怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件（K9、不同卡名、可用素材、可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的超量素材全部转移给新特殊召唤的怪兽。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身作为超量素材重叠到新怪兽下方。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤方式将新怪兽特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- ②效果的发动条件判断：本回合该玩家是否有K9怪兽进行过战斗（通过flag记录）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该玩家持有的flag数量大于0，确认满足“自己的「K9」怪兽进行过战斗”的条件。
	return Duel.GetFlagEffect(tp,id)>0
end
-- ②效果发动时的目标检查与操作信息设置：确认墓地的这张卡可以盖放，并设置“将离开墓地”的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：这张卡将从墓地离开（用于配合王家长眠之谷等卡片的检测）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与连锁关联且不受王家长眠之谷影响，则将其盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否仍与效果关联，并且通过王家长眠之谷的过滤（即不受其“不能从墓地特殊召唤/移动”的限制）。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡盖放到自己场上。
		Duel.SSet(tp,c)
	end
end
