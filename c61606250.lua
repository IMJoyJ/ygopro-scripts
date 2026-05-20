--武装竜の襲雷
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。
-- ①：以自己场上1只「武装龙」怪兽为对象才能发动。从自己的卡组·墓地选那1只同名怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
function c61606250.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。①：以自己场上1只「武装龙」怪兽为对象才能发动。从自己的卡组·墓地选那1只同名怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,61606250+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c61606250.cost)
	e1:SetTarget(c61606250.target)
	e1:SetOperation(c61606250.activate)
	c:RegisterEffect(e1)
	-- 添加自定义活动计数器，用于检测玩家在当前回合是否特殊召唤过非龙族怪兽
	Duel.AddCustomActivityCounter(61606250,ACTIVITY_SPSUMMON,c61606250.counterfilter)
end
-- 计数器过滤函数：判断卡片是否为龙族怪兽
function c61606250.counterfilter(c)
	return c:IsRace(RACE_DRAGON)
end
-- 效果发动代价（Cost）函数：检查并注册本回合不能特殊召唤非龙族怪兽的限制
function c61606250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查本回合是否未曾特殊召唤过非龙族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(61606250,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。①：以自己场上1只「武装龙」怪兽为对象才能发动。从自己的卡组·墓地选那1只同名怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c61606250.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能特殊召唤非龙族怪兽的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制函数：限制不能特殊召唤非龙族怪兽
function c61606250.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON)
end
-- 对象怪兽过滤函数：筛选场上表侧表示的「武装龙」怪兽，且卡组或墓地存在其同名怪兽
function c61606250.filter(c,e,tp)
	-- 判断怪兽是否表侧表示、属于「武装龙」系列，且卡组或墓地存在可检索或特殊召唤的同名怪兽
	return c:IsFaceup() and c:IsSetCard(0x111) and Duel.IsExistingMatchingCard(c61606250.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 目标怪兽过滤函数：筛选卡组或墓地中与对象怪兽同名的怪兽，且该怪兽可以加入手卡或特殊召唤
function c61606250.thfilter(c,e,tp,code)
	if not (c:IsCode(code) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取玩家场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 效果发动准备（Target）函数：确认是否满足发动条件，并选择场上的「武装龙」怪兽作为对象
function c61606250.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c61606250.filter(chkc,e,tp) end
	-- 在发动准备阶段，检查场上是否存在符合条件的「武装龙」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c61606250.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的「武装龙」怪兽作为效果的对象
	Duel.SelectTarget(tp,c61606250.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 效果处理（Activate）函数：将同名怪兽加入手卡或无视召唤条件特殊召唤，并施加不能直接攻击的限制
function c61606250.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向玩家发送提示信息，要求选择要操作的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组或墓地选择1张与对象怪兽同名的怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61606250.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		-- 获取玩家场上可用的怪兽区域数量，用于判断是否可以特殊召唤
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sc=g:GetFirst()
		if sc then
			-- 判断是否只能加入手卡，或者在可以特召且有空位时，让玩家选择是加入手卡还是特殊召唤
			if sc:IsAbleToHand() and (not sc:IsCanBeSpecialSummoned(e,0,tp,true,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将选中的同名怪兽加入手卡
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,sc)
			else
				-- 尝试无视召唤条件将该怪兽以表侧表示特殊召唤到场上
				if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
					-- 这个效果特殊召唤的怪兽不能直接攻击。
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
				end
				-- 完成特殊召唤的处理流程
				Duel.SpecialSummonComplete()
			end
		end
	end
end
