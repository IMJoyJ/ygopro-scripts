--武装竜の襲雷
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。
-- ①：以自己场上1只「武装龙」怪兽为对象才能发动。从自己的卡组·墓地选那1只同名怪兽加入手卡或无视召唤条件特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
function c61606250.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。 ①：以自己场上1只「武装龙」怪兽为对象才能发动。从自己的卡组·墓地选那1只同名怪兽加入手卡或无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,61606250+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c61606250.cost)
	e1:SetTarget(c61606250.target)
	e1:SetOperation(c61606250.activate)
	c:RegisterEffect(e1)
	-- 注册自定义特殊召唤行动计数器，用于检测本回合是否特殊召唤过龙族以外的怪兽
	Duel.AddCustomActivityCounter(61606250,ACTIVITY_SPSUMMON,c61606250.counterfilter)
end
-- 计数器过滤函数，仅对龙族以外的怪兽触发特殊召唤限制计数
function c61606250.counterfilter(c)
	return c:IsRace(RACE_DRAGON)
end
-- 发动代价与誓约检查，确认本回合尚未特殊召唤过非龙族怪兽并注册持续至回合结束的龙族特殊召唤限制
function c61606250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未进行过龙族以外怪兽的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(61606250,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c61606250.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册持续至回合结束的龙族特殊召唤誓约限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件，禁止特殊召唤龙族以外的怪兽
function c61606250.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON)
end
-- 过滤函数，检查是否为自己场上表侧表示的「武装龙」怪兽且卡组·墓地存在可处理的同名怪兽
function c61606250.filter(c,e,tp)
	-- 判断该卡是否为表侧表示「武装龙」怪兽且自己卡组·墓地存在满足条件的同名怪兽
	return c:IsFaceup() and c:IsSetCard(0x111) and Duel.IsExistingMatchingCard(c61606250.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，检查是否为指定卡号的怪兽且能加入手卡或在有空位时可无视召唤条件特殊召唤
function c61606250.thfilter(c,e,tp,code)
	if not (c:IsCode(code) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 检查自己怪兽区是否存在符合条件的「武装龙」怪兽并选择1只作为连锁对象
function c61606250.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c61606250.filter(chkc,e,tp) end
	-- 检查自己怪兽区是否存在至少1只满足条件的「武装龙」怪兽
	if chk==0 then return Duel.IsExistingTarget(c61606250.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示控制者选择自己场上1只「武装龙」怪兽作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己怪兽区1只「武装龙」怪兽作为本次连锁的对象
	Duel.SelectTarget(tp,c61606250.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 效果处理，从卡组·墓地选1只对象怪兽的同名怪兽加入手卡或无视召唤条件特殊召唤，若特召则限制其不能直接攻击
function c61606250.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象选择的「武装龙」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示控制者选择要加入手卡或特殊召唤的同名怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从自己卡组·墓地（受王家长眠之谷限制过滤）选择1只对象怪兽的同名怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61606250.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		-- 获取当前自己怪兽区的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sc=g:GetFirst()
		if sc then
			-- 判断选中的同名怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
			if sc:IsAbleToHand() and (not sc:IsCanBeSpecialSummoned(e,0,tp,true,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将选中的同名怪兽加入自己手卡
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方确认加入手卡的怪兽
				Duel.ConfirmCards(1-tp,sc)
			else
				-- 以分步方式开始将选中的同名怪兽无视召唤条件表侧表示特殊召唤
				if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
					-- 这个效果特殊召唤的怪兽不能直接攻击。
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
				end
				-- 完成分步特殊召唤处理并正式将其视作特殊召唤成功
				Duel.SpecialSummonComplete()
			end
		end
	end
end
