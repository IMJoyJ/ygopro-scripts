--ミミグル・メーカー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把2只卡名不同的反转怪兽给对方观看，对方从那之中随机选1只。那1只在对方场上里侧守备表示特殊召唤，剩余加入自己手卡。那之后，可以从手卡把1只「迷拟宝箱鬼」怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或表侧守备表示。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：将①的检索/特召/回手效果注册为魔法卡发动效果（e1），将②的墓地诱发效果注册为对方特召时的诱发效果（e2）。
function s.initial_effect(c)
	-- ①：从卡组把2只卡名不同的反转怪兽给对方观看，对方从那之中随机选1只。那1只在对方场上里侧守备表示特殊召唤，剩余加入自己手卡。那之后，可以从手卡把1只「迷拟宝箱鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.tgcon2)
	-- 设置②效果的发动代价为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 定义候选反转怪兽的筛选条件：必须为反转怪兽、可被特殊召唤到对方场上里侧守备表示，且可加入手卡。
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and c:IsAbleToHand()
end
-- 定义手卡中「迷拟宝箱鬼」怪兽的筛选条件：属于迷拟宝箱鬼系列且可被表侧表示特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1b7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果发动时的目标判定及操作信息设置：检查卡组中是否存在至少2种卡名不同的候选反转怪兽，且对方场上有空位；并预告特殊召唤和加入手卡的处理。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足spfilter1条件的反转怪兽集合。
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检查候选怪兽的卡名种类数是否不少于2，且对方场上有可用怪兽区域。
		return g:GetClassCount(Card.GetCode)>=2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
	-- 设置操作信息，预告将进行1只怪兽的特殊召唤（来源为卡组，对象不确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	-- 设置操作信息，预告将1张卡加入手卡（来源为卡组，对象不确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选出2只卡名不同的反转怪兽给对方确认，对方随机选1只以里侧守备表示特殊召唤到对方场上，其余加入自己手卡；之后可选择从手卡特殊召唤1只「迷拟宝箱鬼」怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的反转怪兽集合，用于后续选择。
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 确认对方场上有空位且候选卡名种类数足够，保证效果可以处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>=2 then
		-- 弹出选择提示，要求玩家选出要操作的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从候选怪兽中自动选择2只卡名不同的反转怪兽（通过aux.dncheck保证卡名互不相同）。
		local cg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选出的2只反转怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,cg)
		local tc=cg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选中的那只反转怪兽展示给自己玩家确认。
		Duel.ConfirmCards(tp,tc)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) then
			-- 将对方随机选中的那只反转怪兽以里侧守备表示特殊召唤到对方场上。
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			cg:RemoveCard(tc)
			if cg:GetFirst():IsAbleToHand() then
				-- 将剩余的一只反转怪兽加入自己手卡。
				Duel.SendtoHand(cg,nil,REASON_EFFECT)
				-- 检查自己手卡中是否存在可表侧特殊召唤的「迷拟宝箱鬼」怪兽，且自己场上有可用怪兽区域。
				if Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					-- 询问玩家是否发动追加效果，从手卡特殊召唤1只「迷拟宝箱鬼」怪兽。
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从手卡特殊召唤？"
					-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 从手卡选择1只符合条件的「迷拟宝箱鬼」怪兽。
					local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
					if sc then
						-- 中断当前连锁，使后续特殊召唤不与此前效果同时处理，避免错过时点。
						Duel.BreakEffect()
						-- 洗切手卡，以更新手卡顺序（因为可能将手卡怪兽特殊召唤）。
						Duel.ShuffleHand(tp)
						-- 将选择的「迷拟宝箱鬼」怪兽以表侧表示特殊召唤到自己场上。
						Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			else
				-- 若剩余卡片无法加入手卡，则按规则将其送去墓地。
				Duel.SendtoGrave(cg,REASON_RULE)
			end
		end
	end
end
-- ②效果的发动条件：对方成功特殊召唤怪兽。
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义②效果对象的筛选条件：对方场上的里侧守备表示怪兽。
function s.posfilter(c)
	return c:IsFacedown() and c:IsDefensePos()
end
-- ②效果发动时的目标选择及操作信息设置：选择对方场上1只里侧表示怪兽为对象，并预告变更表示形式。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 检查是否存在符合条件的对象（对方场上的里侧表示怪兽）。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上1只里侧守备表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，预告将变更1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- ②效果处理：根据对象当前的表示形式将其变更为表侧攻击表示或表侧守备表示；若对象为里侧表示，则由玩家选择表侧形式后变更。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsCanChangePosition() then
			-- 将对象怪兽变为表侧守备表示。
			Duel.ChangePosition(tc,POS_FACEUP_DEFENCE)
		elseif tc:IsPosition(POS_FACEUP_DEFENCE) and tc:IsCanChangePosition() then
			-- 将对象怪兽变为表侧攻击表示。
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		else
			-- 对象为里侧表示时，由当前玩家选择要变成的表侧攻击或守备表示。
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP)
			-- 按选择的形式变更对象怪兽的表示形式。
			Duel.ChangePosition(tc,pos)
		end
	end
end
