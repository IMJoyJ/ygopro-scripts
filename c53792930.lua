--K9－EX強制解除
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己场上1只「K9」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。
-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果：①效果为可在主要阶段取对象发动，从额外卡组超量特殊召唤另一只「K9」超量怪兽并可选破坏对方1张卡；②效果为战斗阶段结束时从墓地盖放自身；同时注册全局战斗检测以记录本回合有「K9」怪兽战斗。
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只「K9」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
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
		-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，以自己场上1只「K9」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		-- 将监听战斗事件的全局效果ge1注册到全场（双方通用），用于持续记录「K9」怪兽参与战斗的情况。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗事件处理函数：在每次伤害计算后，检查攻击怪兽和攻击目标中是否存在「K9」怪兽，若有则为该控制者注册本回合进行过「K9」战斗的标志。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的被攻击目标怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	-- 获取本次战斗发动攻击的怪兽。
	local ar=Duel.GetAttacker()
	if at and at:IsSetCard(0x1cb) then
		-- 为攻击目标的控制者注册一个到结束阶段重置的「K9」战斗标志（数量+1），表示其在本回合有「K9」怪兽参与了战斗。
		Duel.RegisterFlagEffect(at:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
	if ar and ar:IsSetCard(0x1cb) then
		-- 为攻击怪兽的控制者注册一个到结束阶段重置的「K9」战斗标志（数量+1），表示其在本回合有「K9」怪兽参与了战斗。
		Duel.RegisterFlagEffect(ar:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ①效果的发动条件：只能在主要阶段发动，对应原文‘自己·对方的主要阶段’。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 定义可作为①效果对象的卡：自己场上表侧表示的「K9」超量怪兽，且能够作为超量素材，并且额外卡组存在可特殊召唤的另一只不同卡名「K9」超量怪兽。
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x1cb)
		-- 确认该对象没有被‘不能作为超量素材’等效果限制，可以成为超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认额外卡组中至少有1只满足filter2条件的另一只「K9」超量怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
end
-- 定义额外卡组中可被①效果特殊召唤的怪兽：是「K9」超量怪兽，与对象怪兽卡名不同，能以对象怪兽为素材进行超量召唤，且存在可用额外怪兽区空格。
function s.filter2(c,e,tp,mc,code)
	return c:IsSetCard(0x1cb) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 确认该候选怪兽满足超量召唤的特殊召唤条件，并且场上/额外怪兽区有足够的空格可供特殊召唤。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果发动的目标选择与操作信息设定：从自己场上选择1只符合条件的「K9」超量怪兽作为对象，并记录后续将从额外卡组超量特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 效果发动合法性检查：若自己场上不存在符合条件的「K9」超量怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 向玩家显示‘请选择效果的对象’的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「K9」超量怪兽作为效果对象，并自动关联为连锁对象。
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息设置为‘从额外卡组特殊召唤1只怪兽’，供相关卡牌/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理时，取得对象并验证其是否仍然有效：若对象已不能作为素材、变成里侧表示、与连锁失去关联、控制权转移或对此效果免疫，则整个效果不处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍未被‘不能作为超量素材’效果限制；已被限制则中止处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家显示‘请选择要特殊召唤的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只符合条件的「K9」超量怪兽（与对象卡名不同）用于重叠超量召唤。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的超量素材全部转移给新特殊召唤的怪兽，使其继承这些素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽本身重叠到新特殊召唤的怪兽下方，完成‘在作为对象的怪兽上面重叠’的超量召唤素材处理。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的怪兽以超量召唤方式表侧表示特殊召唤到自己的怪兽区（SUMMON_TYPE_XYZ）。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 检查对方场上是否存在至少1张卡，用于决定是否提供追加破坏的选项。
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
			-- 弹窗询问玩家‘是否把卡破坏？’，若选择否则不进行后续破坏处理。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
			-- 中断当前效果链，使接下来的破坏处理被视为另一次效果处理，避免时点冲突。
			Duel.BreakEffect()
			-- 向玩家显示‘请选择要破坏的卡’的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择对方场上的1张卡作为破坏对象。
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 为选中的破坏对象播放选中动画，并记录其成为对象（广义）。
			Duel.HintSelection(g)
			-- 以效果破坏原因将选择的那张卡破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：本回合内自己场上有「K9」怪兽进行过战斗（通过标志判断），且当前为战斗阶段结束时。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回玩家本回合是否拥有「K9」战斗标志（数量>0），有则满足②发动条件。
	return Duel.GetFlagEffect(tp,id)>0
end
-- ②效果的目标处理：确认墓地的此卡可以盖放，并设置操作信息为离开墓地（盖放）。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为‘墓地的这张卡将离开墓地’，用于连锁触发相关检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：将墓地的此卡盖放到自己魔陷区；若此卡已不相关或受王家长眠之谷影响则无法处理。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与连锁相关且不受‘王家长眠之谷’的墓地区效果限制，满足从墓地盖放的条件。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以里侧表示盖放到自己场上（魔陷区）。
		Duel.SSet(tp,c)
	end
end
