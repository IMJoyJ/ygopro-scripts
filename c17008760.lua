--原質の円環炉
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上1个超量素材取除。取除的超量素材被送去自己墓地的场合，可以再把那张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果，设置为发动时点、自由连锁、发动次数限制为1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 设置效果的满足条件，检查是否能移除自己场上的1个超量素材
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除自己场上的1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- 效果发动时的处理流程，选择要取除超量素材的怪兽并执行取除操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要取除超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 选择满足条件的怪兽，移除其1个超量素材
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,0,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	if sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		-- 获取实际被操作的卡片组，获取其中第一张卡
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 判断被取除的超量素材是否在自己墓地且未受王家长眠之谷影响
		if tc and tc:IsControler(tp) and tc:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(tc) then
			-- 判断被取除的超量素材是否为怪兽卡且场上还有空位
			if tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 询问玩家是否将该卡盖放
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把那张卡盖放？"
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将该卡特殊召唤到自己场上（里侧守备形式）
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 向对方确认该卡的盖放
				Duel.ConfirmCards(1-tp,tc)
			-- 判断被取除的超量素材是否为场地卡或自己魔法陷阱区有空位
			elseif (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
				-- 询问玩家是否将该卡盖放
				and tc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把那张卡盖放？"
				-- 中断当前效果处理，使后续处理视为错时点
				Duel.BreakEffect()
				-- 将该卡盖放到自己场上
				Duel.SSet(tp,tc)
			end
		end
	end
end
