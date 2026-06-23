--巳剣勧請
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己的手卡·场上1只爬虫类族怪兽解放来发动。
-- ①：从以下效果选1个适用。把怪兽解放来把这张卡发动的场合，可以选两方适用。
-- ●从卡组把1只「巳剑」怪兽加入手卡。
-- ●自己受到800伤害。那之后，可以从自己的手卡·墓地把1只「巳剑」怪兽特殊召唤。这个效果特殊召唤的怪兽不能直接攻击。
local s,id,o=GetID()
-- 创建效果，设置发动时的提示信息、效果分类、发动类型、连锁时点、发动次数限制和处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己的手卡·场上1只爬虫类族怪兽解放来发动。
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
-- 判断目标是否为爬虫类族怪兽，且处于控制者手中或场上正面表示状态
function s.costfilter(c,tp)
	return (c:IsControler(tp) or c:IsFaceup())
		and c:IsRace(RACE_REPTILE)
end
-- 判断目标是否为巳剑卡组的怪兽卡且可以加入手牌
function s.filter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断目标是否为巳剑卡组的怪兽卡且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c3)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的选择处理，检查是否满足发动条件并选择是否解放怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的巳剑怪兽
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	e:SetLabel(0)
	if chk==0 then return b1 or b2 end
	-- 检查玩家场上或手卡是否存在满足条件的爬虫类族怪兽
	if e:IsCostChecked() and Duel.CheckReleaseGroupEx(tp,s.costfilter,1,REASON_COST,true,nil,tp)
		-- 询问玩家是否选择解放怪兽来发动此卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否解放怪兽来发动？"
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择满足条件的1张卡进行解放
		local g=Duel.SelectReleaseGroupEx(tp,s.costfilter,1,1,REASON_COST,true,nil,tp)
		-- 执行解放操作
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	end
	-- 设置发动时的操作信息，准备将卡组中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理发动效果，根据选择执行检索或伤害+特殊召唤的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=0
	-- 检查卡组中是否存在满足条件的巳剑怪兽
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	local b2=true
	-- 询问玩家是否选择从卡组加入手牌
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否从卡组加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的1张卡加入手牌
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
		op=1
	end
	-- 询问玩家是否选择受到800伤害并特殊召唤
	if b2 and (op==0 or e:GetLabel()==1 and Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否受到伤害？"
		if op~=0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 对玩家造成800点伤害
		if Duel.Damage(tp,800,REASON_EFFECT)<=0 then return end
		-- 检查是否有可用怪兽区域并判断是否可以特殊召唤巳剑怪兽
		local b3=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择特殊召唤
		if b3 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的1张卡进行特殊召唤
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
			local tc=g:GetFirst()
			if tc then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 特殊召唤选中的卡
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 给特殊召唤的怪兽添加不能直接攻击的效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 完成特殊召唤处理
				Duel.SpecialSummonComplete()
			end
		end
	end
end
