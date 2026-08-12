--ピンポイント奪取
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方各自选自身的额外卡组1张里侧表示的卡。那些卡给双方确认，相同种类（融合·同调·超量·连接）的场合，对方选的卡送去墓地，自己选的卡特殊召唤。并且原本的种族·属性相同的场合，再让对方失去自身选的卡的攻击力数值的基本分。不同种类的场合，自己选的卡送去墓地，对方把自身选的卡特殊召唤。
function c94431029.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：双方各自选自身的额外卡组1张里侧表示的卡。那些卡给双方确认，相同种类（融合·同调·超量·连接）的场合，对方选的卡送去墓地，自己选的卡特殊召唤。并且原本的种族·属性相同的场合，再让对方失去自身选的卡的攻击力数值的基本分。不同种类的场合，自己选的卡送去墓地，对方把自身选的卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,94431029+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c94431029.target)
	e1:SetOperation(c94431029.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动时的目标检查（Target），确认双方额外卡组是否都至少有1张里侧表示的卡
function c94431029.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方额外卡组是否存在至少1张里侧表示的卡
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)>0
		-- 检查对方额外卡组是否存在至少1张里侧表示的卡
		and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)>0 end
end
-- 定义卡片发动后的效果处理（Operation），执行双方选卡、确认、比对种类并根据结果进行送墓、特殊召唤以及扣除生命值的处理
function c94431029.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组中所有里侧表示的卡
	local g1=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)
	-- 获取对方额外卡组中所有里侧表示的卡
	local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if g1:GetCount()<=0 or g2:GetCount()<=0 then return end
	-- 提示己方玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc1=g1:Select(tp,1,1,nil):GetFirst()
	-- 提示对方玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc2=g2:Select(1-tp,1,1,nil):GetFirst()
	local tg=Group.FromCards(tc1,tc2)
	-- 将双方选择的卡给双方玩家确认
	Duel.ConfirmCards(tp,tg)
	local res=false
	for i,type in ipairs({TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}) do
		if tc1:IsType(type) and tc2:IsType(type) then
			res=true
			break
		end
	end
	if res then
		-- 相同种类时，尝试将对方选的卡因效果送去墓地，并确认其已成功送入墓地
		if Duel.SendtoGrave(tc2,REASON_EFFECT)~=0 and tc2:IsLocation(LOCATION_GRAVE)
			and tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 检查己方额外怪兽区域是否有空位，并将自己选的卡在己方场上表侧表示特殊召唤
			if Duel.GetLocationCountFromEx(tp,tp,nil,tc1)>0 and Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)~=0 then
				if tc1:GetOriginalRace()==tc2:GetOriginalRace() and tc1:GetOriginalAttribute()==tc2:GetOriginalAttribute() then
					-- 中断当前效果，使后续的扣除生命值处理与特殊召唤不视为同时进行
					Duel.BreakEffect()
					local atk=tc2:GetTextAttack()
					-- 扣除对方玩家等同于其所选怪兽攻击力数值的生命值
					Duel.SetLP(1-tp,Duel.GetLP(1-tp)-atk)
				end
			end
		end
	else
		-- 不同种类时，尝试将自己选的卡因效果送去墓地，并确认其已成功送入墓地
		if Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_GRAVE)
			and tc2:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP,1-tp) then
			-- 检查对方额外怪兽区域是否有空位
			if Duel.GetLocationCountFromEx(1-tp,1-tp,nil,tc2)>0 then
				-- 将对方选的卡在对方场上表侧表示特殊召唤
				Duel.SpecialSummon(tc2,0,1-tp,1-tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 洗切己方的额外卡组
	Duel.ShuffleExtra(tp)
	-- 洗切对方的额外卡组
	Duel.ShuffleExtra(1-tp)
end
