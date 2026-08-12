--コンベックス・ナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有机械族怪兽存在的场合才能发动。这张卡守备表示特殊召唤。那之后，可以把这张卡的等级变成和场上1只机械族怪兽的等级·阶级的数值相同。
-- ②：自己主要阶段才能发动。从卡组把1只机械族·地属性怪兽送去墓地。那之后，这张卡的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果为手牌发动的特殊召唤效果，②效果为场上的起动效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有机械族怪兽存在的场合才能发动。这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把1只机械族·地属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上满足条件的机械族怪兽，排除等级或阶级与指定值相同的怪兽
function s.mcmfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
		and (not lv or c:GetLevel()>0 and c:GetLevel()~=lv or c:GetRank()>0 and c:GetRank()~=lv)
end
-- 判断场上有无机械族怪兽，用于①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有无机械族怪兽，用于①效果的发动条件
	return Duel.IsExistingMatchingCard(s.mcmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置①效果的目标，检查是否有足够的召唤位置和特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，执行特殊召唤并可选择改变等级
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 执行特殊召唤操作，若成功则继续处理后续逻辑
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 获取场上所有满足条件的机械族怪兽，用于选择改变等级的目标
		local g=Duel.GetMatchingGroup(s.mcmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetLevel())
		-- 判断是否有符合条件的怪兽且玩家选择改变等级
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变等级？"
			-- 提示玩家选择表侧表示的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local tg=g:Select(tp,1,1,nil)
			if tg:GetCount()>0 then
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 为选中的卡显示被选为对象的动画效果
				Duel.HintSelection(tg)
				local tc=tg:GetFirst()
				local lv=tc:GetLevel()
				if tc:IsType(TYPE_XYZ) then
					lv=tc:GetRank()
				end
				-- 设置等级改变效果，使此卡等级变为选中怪兽的等级或阶级
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤函数，用于筛选卡组中满足条件的机械族地属性怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置②效果的目标，检查卡组中是否有满足条件的怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组送去墓地1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，执行送去墓地并使此卡攻击力上升
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只满足条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认怪兽被送去墓地且在墓地位置
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=tc:GetLevel()
		if lv>0 and c:IsFaceup() and c:IsRelateToChain() then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 设置攻击力上升效果，使此卡攻击力上升送去墓地怪兽等级×100
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(lv*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
