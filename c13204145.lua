--ミミグル・メーカー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把2只卡名不同的反转怪兽给对方观看，对方从那之中随机选1只。那1只在对方场上里侧守备表示特殊召唤，剩余加入自己手卡。那之后，可以从手卡把1只「迷拟宝箱鬼」怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或表侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：从卡组把2只卡名不同的反转怪兽给对方观看，对方从那之中随机选1只。那1只在对方场上里侧守备表示特殊召唤，剩余加入自己手卡。那之后，可以从手卡把1只「迷拟宝箱鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.tgcon2)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的反转怪兽
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and c:IsAbleToHand()
end
-- 过滤满足条件的迷拟宝箱鬼怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1b7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果的处理目标设定
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的反转怪兽组
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断是否满足发动条件
		return g:GetClassCount(Card.GetCode)>=2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
	-- 设置特殊召唤的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	-- 设置回手牌的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的反转怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判断是否满足发动条件
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>=2 then
		-- 提示选择卡牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		-- 选择2只卡名不同的反转怪兽
		local cg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 向对方展示所选的反转怪兽
		Duel.ConfirmCards(1-tp,cg)
		local tc=cg:RandomSelect(1-tp,1):GetFirst()
		-- 向自己展示被选中的反转怪兽
		Duel.ConfirmCards(tp,tc)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) then
			-- 将被选中的反转怪兽特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			cg:RemoveCard(tc)
			if cg:GetFirst():IsAbleToHand() then
				-- 将剩余的反转怪兽加入自己手牌
				Duel.SendtoHand(cg,nil,REASON_EFFECT)
				-- 判断手牌中是否存在迷拟宝箱鬼怪兽
				if Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					-- 询问是否发动后续效果
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					-- 提示选择特殊召唤的卡牌
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					-- 选择要特殊召唤的迷拟宝箱鬼怪兽
					local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
					if sc then
						-- 中断当前效果处理
						Duel.BreakEffect()
						-- 洗切自己的手牌
						Duel.ShuffleHand(tp)
						-- 将所选的迷拟宝箱鬼怪兽特殊召唤到自己场上
						Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			else
				-- 将未被特殊召唤的反转怪兽送入墓地
				Duel.SendtoGrave(cg,REASON_RULE)
			end
		end
	end
end
-- 效果发动条件判断
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤里侧守备表示的怪兽
function s.posfilter(c)
	return c:IsFacedown() and c:IsDefensePos()
end
-- 效果的目标设定
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 判断是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择改变表示形式
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 效果的处理执行
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		if tc:IsPosition(POS_FACEUP_ATTACK) and tc:IsCanChangePosition() then
			-- 将目标怪兽变为表侧守备表示
			Duel.ChangePosition(tc,POS_FACEUP_DEFENCE)
		elseif tc:IsPosition(POS_FACEUP_DEFENCE) and tc:IsCanChangePosition() then
			-- 将目标怪兽变为表侧攻击表示
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		else
			-- 选择目标怪兽的表示形式
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP)
			-- 将目标怪兽变为指定表示形式
			Duel.ChangePosition(tc,pos)
		end
	end
end
