--巳剣勧請
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己的手卡·场上1只爬虫类族怪兽解放来发动。
-- ①：从以下效果选1个适用。把怪兽解放来把这张卡发动的场合，可以选两方适用。
-- ●从卡组把1只「巳剑」怪兽加入手卡。
-- ●自己受到800伤害。那之后，可以从自己的手卡·墓地把1只「巳剑」怪兽特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
local s,id,o=GetID()
-- function s.initial_effect(c) 为巳剑劝请注册其作为魔法卡的发动效果：创建效果e1，设置描述、类别、类型为发动、发动时点为自由时点、1回合1次限制、指定目标与处理函数，并注册到卡片上。
function s.initial_effect(c)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。这张卡也能把自己的手卡·场上1只爬虫类族怪兽解放来发动。①：从以下效果选1个适用。把怪兽解放来把这张卡发动的场合，可以选两方适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 解放代价的过滤函数：判断候选卡是否为爬虫类族怪兽，且满足控制者为己方或表侧表示（用于从手卡·场上选择可解放的爬虫类族怪兽）。
function s.costfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and c:IsRace(RACE_REPTILE)
end
-- 检索过滤函数：判断卡是否为「巳剑」系列怪兽且可以被加入手卡，用于从卡组选出1只符合条件的「巳剑」怪兽。
function s.filter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 特殊召唤过滤函数：判断卡是否为「巳剑」系列怪兽且可以被当前效果特殊召唤（检查召唤条件和苏生限制），用于从手卡·墓地选择特招对象。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c3)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标与代价处理函数：先判断是否存在可检索对象或可选的伤害分支；若玩家选择解放手卡·场上1只爬虫类族怪兽来发动，则在此完成解放并记录标记；最后设置操作信息为从卡组将1张卡加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1张满足检索过滤条件的「巳剑」怪兽，作为是否可执行检索分支的依据。
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	e:SetLabel(0)
	if chk==0 then return b1 or b2 end
	-- 检查当前为代价确认阶段，且己方手卡·场上存在至少1只可解放的爬虫类族怪兽，以决定是否提供解放发动的选项。
	if e:IsCostChecked() and Duel.CheckReleaseGroupEx(tp,s.costfilter,1,REASON_COST,true,nil,tp)
		-- 询问玩家是否解放怪兽来发动；选择是才继续执行解放操作。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否解放怪兽来发动？"
		-- 发出选择提示，通知玩家接下来需要选择要解放的卡（显示“请选择要解放的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让玩家从自己的手卡·场上选择1只符合解放过滤条件的爬虫类族怪兽。
		local g=Duel.SelectReleaseGroupEx(tp,s.costfilter,1,1,REASON_COST,true,nil,tp)
		-- 将选择的爬虫类族怪兽作为发动代价解放。
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	end
	-- 设置操作信息：此效果处理后可能从卡组将1张卡加入手卡（对象未定，数量为1），供其他卡与系统检测检索行为。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：先执行检索分支（可选），再执行伤害与特殊召唤分支；若选择了解放发动（label为1）则可两方同时适用；特招的怪兽会被附加不能直接攻击的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=0
	-- 效果处理时再次检查卡组中是否存在满足检索条件的「巳剑」怪兽，以决定是否向玩家提供检索选项。
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	-- 若存在可检索的卡片，且玩家确认选择“从卡组加入手卡”，则进入检索处理；由于b2恒为真，实际通过询问玩家决定是否执行。
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否从卡组加入手卡？"
		-- 发出选择提示，通知玩家选择要加入手牌的卡（显示“请选择要加入手牌的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足检索过滤条件的「巳剑」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「巳剑」怪兽加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡，完成确认。
			Duel.ConfirmCards(1-tp,g)
		end
		op=1
	end
	-- 判断是否执行伤害分支：若尚未执行检索分支（op==0），则必须执行；若已执行检索，则只有解放发动时（label==1）才可选第二效果并询问玩家是否受到800伤害。
	if b2 and (op==0 or e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否受到伤害？"
		if op~=0 then
			-- 中断当前效果处理，使检索和后续伤害/特招分为不同时点处理，防止错过时点。
			Duel.BreakEffect()
		end
		-- 对己方造成800点效果伤害；若实际伤害为0（例如被伤害替换效果影响），则终止后续处理，不再执行特殊召唤。
		if Duel.Damage(tp,800,REASON_EFFECT)<=0 then return end
		-- 检查己方怪兽区是否有空位，且手卡·墓地中存在不受王家长眠之谷影响的、可特殊召唤的「巳剑」怪兽，作为特招分支是否可行的条件。
		local b3=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 若满足特招条件，且玩家选择进行特殊召唤，则进入特招处理。
		if b3 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
			-- 发出选择提示，通知玩家选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡·墓地选择1只满足条件且不受王家长眠之谷影响的「巳剑」怪兽。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				-- 中断当前效果处理，使伤害与特殊召唤分为不同时点处理，单独触发特殊召唤相关时点。
				Duel.BreakEffect()
				-- 以表侧攻击表示将选择的「巳剑」怪兽特殊召唤到己方场上；使用分解步骤以便在特招成功前附加后续的不能直接攻击效果。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 对应效果原文：这个效果特殊召唤的怪兽不能直接攻击。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 完成特殊召唤的收尾处理，正式宣告特殊召唤成功并触发时点。
				Duel.SpecialSummonComplete()
			end
		end
	end
end
