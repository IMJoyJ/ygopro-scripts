--K9－EX強制解除
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，以自己场上1只「K9」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「K9」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以把对方场上1张卡破坏。
-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册主效果，设置为自由连锁，可选择对象，限制只能在主要阶段发动，且每回合只能发动一次
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只「K9」超量怪兽为对象才能发动。
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
	-- ②：自己的「K9」怪兽进行战斗的回合的战斗阶段结束时才能发动。
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
		-- 注册全局战斗时点检测效果，用于记录参与战斗的K9怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetOperation(s.checkop)
		-- 将全局战斗时点检测效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 战斗时点处理函数，记录参与战斗的K9怪兽控制者
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local at=Duel.GetAttackTarget()
	-- 获取被攻击怪兽
	local ar=Duel.GetAttacker()
	if at and at:IsSetCard(0x1cb) then
		-- 为攻击怪兽的控制者注册标识效果，用于标记该怪兽参与过战斗
		Duel.RegisterFlagEffect(at:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
	if ar and ar:IsSetCard(0x1cb) then
		-- 为被攻击怪兽的控制者注册标识效果，用于标记该怪兽参与过战斗
		Duel.RegisterFlagEffect(ar:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否处于主要阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤满足条件的K9超量怪兽，用于作为效果对象
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x1cb)
		-- 检查该怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的额外卡组中的K9超量怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
end
-- 过滤满足条件的额外卡组中的K9超量怪兽，用于特殊召唤
function s.filter2(c,e,tp,mc,code)
	return c:IsSetCard(0x1cb) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤且场上存在足够的位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标，选择符合条件的K9超量怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	-- 检查是否有满足条件的K9超量怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的K9超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动处理函数，获取目标怪兽并进行后续处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToChain() or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的K9超量怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将召唤的怪兽特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 检查对方场上是否存在可破坏的卡
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
			-- 询问玩家是否破坏对方场上的卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择对方场上的卡作为破坏对象
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 显示被选为对象的卡的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 判断是否满足盖放条件，即该回合有K9怪兽参与过战斗
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回该玩家是否拥有标识效果
	return Duel.GetFlagEffect(tp,id)>0
end
-- 设置盖放效果的目标信息，表示将要盖放此卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果处理函数，将此卡盖放到场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以盖放
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡盖放到场上
		Duel.SSet(tp,c)
	end
end
