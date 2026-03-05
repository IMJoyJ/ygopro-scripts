--ミミグル・メーカー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把2只卡名不同的反转怪兽给对方观看，对方从那之中随机选1只。那1只在对方场上里侧守备表示特殊召唤，剩余加入自己手卡。那之后，可以从手卡把1只「迷拟宝箱鬼」怪兽特殊召唤。
-- ②：对方把怪兽特殊召唤的场合，把墓地的这张卡除外，以对方场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示或表侧守备表示。
local s,id,o=GetID()
-- 注册两个效果，第一个为检索效果，第二个为对方怪兽特殊召唤时的发动效果
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
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的反转怪兽，可特殊召唤且能回手
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and c:IsAbleToHand()
end
-- 筛选满足条件的「迷拟宝箱鬼」怪兽，可特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1b7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断是否满足发动条件，即卡组中存在至少2张不同卡名的反转怪兽且对方场上有空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足spfilter1条件的卡组卡片
		local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断满足条件的反转怪兽数量是否不少于2且对方场上有空位
		return g:GetClassCount(Card.GetCode)>=2 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
	-- 设置连锁操作信息，表示将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	-- 设置连锁操作信息，表示将1张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动，从卡组选择2张不同卡名的反转怪兽，对方随机选择1张特殊召唤，其余送入手牌，然后可从手卡特殊召唤1只迷拟宝箱鬼怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足spfilter1条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判断满足条件的反转怪兽数量是否不少于2且对方场上有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and g:GetClassCount(Card.GetCode)>=2 then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从满足条件的卡组中选择2张不同卡名的反转怪兽
		local cg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 向对方展示所选的反转怪兽
		Duel.ConfirmCards(1-tp,cg)
		local tc=cg:RandomSelect(1-tp,1):GetFirst()
		-- 向玩家展示对方选择的反转怪兽
		Duel.ConfirmCards(tp,tc)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) then
			-- 将对方选择的反转怪兽特殊召唤到对方场上
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			cg:RemoveCard(tc)
			if cg:GetFirst():IsAbleToHand() then
				-- 将未被选择的反转怪兽送入玩家手牌
				Duel.SendtoHand(cg,nil,REASON_EFFECT)
				-- 判断玩家手牌中是否存在迷拟宝箱鬼怪兽且自己场上有空位
				if Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
					-- 询问玩家是否从手卡特殊召唤迷拟宝箱鬼怪兽
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从手卡特殊召唤？"
					-- 提示玩家选择要特殊召唤的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 选择手牌中满足条件的迷拟宝箱鬼怪兽
					local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
					if sc then
						-- 中断当前效果处理
						Duel.BreakEffect()
						-- 洗切玩家手牌
						Duel.ShuffleHand(tp)
						-- 将玩家选择的迷拟宝箱鬼怪兽特殊召唤到自己场上
						Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			else
				-- 将未被选择的反转怪兽送入墓地
				Duel.SendtoGrave(cg,REASON_RULE)
			end
		end
	end
end
-- 判断是否满足发动条件，即对方有怪兽特殊召唤成功
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 筛选满足条件的里侧守备表示怪兽
function s.posfilter(c)
	return c:IsFacedown() and c:IsDefensePos()
end
-- 设置效果目标，选择对方场上的1只里侧守备表示怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 判断是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择对方场上的1只里侧守备表示怪兽
	Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表示将改变1只怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 处理效果发动，将目标怪兽变为表侧攻击表示或表侧守备表示
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
			-- 让玩家选择目标怪兽的表示形式
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP)
			-- 将目标怪兽变为玩家选择的表示形式
			Duel.ChangePosition(tc,pos)
		end
	end
end
