--神風のドラグニティ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己墓地有「龙之溪谷」存在的场合，以下效果各能适用。不存在的场合，从以下效果选1个适用。
-- ●从自己墓地把1只龙族·鸟兽族怪兽加入手卡。
-- ●从手卡把1只「龙骑兵团」怪兽特殊召唤。那之后，可以从卡组把1只龙族「龙骑兵团」怪兽当作装备魔法卡使用给这个效果特殊召唤的怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动（作为场地魔法）以及在场上发动的起动效果
function s.initial_effect(c)
	-- 将「龙之溪谷」的卡号加入此卡的关联卡片列表中
	aux.AddCodeList(c,62265044)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己墓地有「龙之溪谷」存在的场合，以下效果各能适用。不存在的场合，从以下效果选1个适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
-- 过滤条件：用于检索墓地中可以加入手卡的龙族或鸟兽族怪兽
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 过滤条件：用于检索手卡中可以特殊召唤的「龙骑兵团」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：用于检索卡组中可以作为装备卡装备的龙族「龙骑兵团」怪兽
function s.eqfilter(c,tp)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果发动时的合法性检查，判断是否至少能适用其中一个效果
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以加入手卡的龙族或鸟兽族怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 检查自己手卡是否存在可以特殊召唤的「龙骑兵团」怪兽，且怪兽区域有空位
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2 end
end
-- 效果处理的核心逻辑，根据墓地是否存在「龙之溪谷」来决定是适用两个效果还是选择其中一个适用
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在不受「王家之谷」影响的、可加入手卡的龙族或鸟兽族怪兽
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 检查手卡特殊召唤效果是否满足适用条件
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local op=0
	if b1 then
		-- 如果无法进行特殊召唤，或者玩家选择执行加入手卡的效果
		if not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把卡加入手卡？"
			-- 在界面上提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从墓地选择1张不受「王家之谷」影响的龙族或鸟兽族怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的怪兽加入玩家手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 让对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,g)
			end
			op=1
		end
	end
	-- 重新检查手卡特殊召唤的条件是否依然满足
	b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 如果满足特召条件，且（未执行过回收效果，或者墓地有「龙之溪谷」且玩家选择执行特召效果）
	if b2 and (op==0 or Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,62265044) and Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否特殊召唤？"
		if op~=0 then
			-- 中断当前效果处理，使后续的特殊召唤与前面的回收不视为同时处理
			Duel.BreakEffect()
		end
		-- 在界面上提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1只符合条件的「龙骑兵团」怪兽
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		-- 将选中的怪兽特殊召唤，并检查是否特殊召唤成功
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
			-- 检查卡组中是否存在可装备的龙族「龙骑兵团」怪兽
			and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,tp)
			-- 检查自己场上是否有空余的魔法与陷阱区域
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 询问玩家是否选择将卡组的怪兽作为装备卡装备
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把怪兽装备？"
			-- 中断当前效果处理，使后续的装备处理与前面的特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 在界面上提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 让玩家从卡组选择1只符合条件的龙族「龙骑兵团」怪兽
			local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
			-- 将选中的卡组怪兽作为装备卡装备给特殊召唤的怪兽，并检查是否装备成功
			if ec and Duel.Equip(tp,ec,tc) then
				-- 当作装备魔法卡使用给这个效果特殊召唤的怪兽装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(tc)
				ec:RegisterEffect(e1)
			end
		end
	end
end
-- 装备限制函数，限制该装备卡只能装备给本次效果特殊召唤的那只怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
