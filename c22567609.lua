--素早いモモンガ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，自己回复1000基本分。并且可以再从卡组把「迅捷鼯鼠」任意数量里侧守备表示特殊召唤。
function c22567609.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，自己回复1000基本分。并且可以再从卡组把「迅捷鼯鼠」任意数量里侧守备表示特殊召唤。
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
-- 判定效果发动条件：这张卡被战斗破坏后已送去墓地，且破坏原因是战斗；若满足则本诱发必发效果可以发动。
function c22567609.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 效果发动时的目标处理：该效果没有一个固定的对象，只要满足条件就直接可发动；同时把回复基本分的操作信息登记到当前连锁，供后续处理及规则检测使用。
function c22567609.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：给当前玩家回复1000基本分，回复类别为回复LP，以便其他卡（如星尘龙等）能正确连锁该效果。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 定义筛选函数：从卡组中选取卡名为「迅捷鼯鼠」（22567609），并且可以被当前效果以里侧守备表示特殊召唤的卡。
function c22567609.filter(c,e,tp)
	return c:IsCode(22567609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理：先回复1000基本分；若主要怪兽区有空位，则检测青眼精灵龙的限制，随后从卡组选择任意数量符合条件的「迅捷鼯鼠」里侧守备表示特殊召唤，并向对方确认这些卡。
function c22567609.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家主要怪兽区的空余格子数，用于判断能够特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 以效果原因让当前玩家回复1000基本分。
	Duel.Recover(tp,1000,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 在卡组中检索所有满足c22567609.filter条件的「迅捷鼯鼠」，构成备选特殊召唤的卡组。
	local g=Duel.GetMatchingGroup(c22567609.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若卡组中存在可特殊召唤的「迅捷鼯鼠」，则询问玩家是否发动追加的特殊召唤处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22567609,1)) then  --"是否要特殊召唤？"
		-- 中断当前效果处理，使回复基本分和随后的特殊召唤视作不同的处理阶段，以避免因同一处理中的连锁导致时点错失。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要特殊召唤的卡”的提示，并将选择消息写入缓存，供随后的卡牌选择使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将玩家选出的「迅捷鼯鼠」以里侧守备表示特殊召唤到其场上，不检查召唤条件、不解除苏生限制。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对手确认被特殊召唤的这几张卡，确保信息透明。
		Duel.ConfirmCards(1-tp,sg)
	end
end
