--素早いモモンガ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，自己回复1000基本分。并且可以再从卡组把「迅捷鼯鼠」任意数量里侧守备表示特殊召唤。
function c22567609.initial_effect(c)
	-- 创建一个诱发必发效果，当此卡被战斗破坏送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22567609,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22567609.condition)
	e1:SetTarget(c22567609.target)
	e1:SetOperation(c22567609.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡在墓地且因战斗破坏
function c22567609.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 设置效果处理时的OperationInfo，包含回复LP的效果
function c22567609.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复1000基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 过滤函数，用于筛选可以特殊召唤的「迅捷鼯鼠」
function c22567609.filter(c,e,tp)
	return c:IsCode(22567609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理函数，执行回复LP并可能特殊召唤「迅捷鼯鼠」
function c22567609.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 使自己回复1000基本分
	Duel.Recover(tp,1000,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 从卡组中检索满足条件的「迅捷鼯鼠」卡片组
	local g=Duel.GetMatchingGroup(c22567609.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若检索到卡片且玩家选择特殊召唤，则继续处理
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22567609,1)) then  --"是否要特殊召唤？"
		-- 中断当前连锁处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选中的卡片以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
