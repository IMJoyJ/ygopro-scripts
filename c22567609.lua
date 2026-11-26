--素早いモモンガ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，自己回复1000基本分。并且可以再从卡组把「迅捷鼯鼠」任意数量里侧守备表示特殊召唤。
function c22567609.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，自己回复1000基本分。并且可以再从卡组把「迅捷鼯鼠」任意数量里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22567609,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22567609.condition)
	e1:SetTarget(c22567609.target)
	e1:SetOperation(c22567609.operation)
	c:RegisterEffect(e1)
end
-- 发动条件检查：确认这张卡当前位于墓地且其送去墓地的原因包含战斗破坏
function c22567609.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and bit.band(e:GetHandler():GetReason(),REASON_BATTLE)~=0
end
-- 发动检测与连锁信息设置：因是必发诱发效果，直接返回true并登记己方回复1000基本分的操作信息
function c22567609.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁的回复基本分操作信息，预计使己方回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 筛选条件：检查卡片是否为「迅捷鼯鼠」且能以里侧守备表示特殊召唤
function c22567609.filter(c,e,tp)
	return c:IsCode(22567609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理流程：先使己方回复1000基本分，再在己方怪兽区有空位时可选从卡组里侧守备表示特殊召唤任意数量的「迅捷鼯鼠」并向对方展示
function c22567609.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 以效果使己方回复1000基本分
	Duel.Recover(tp,1000,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取己方卡组中所有可里侧守备表示特殊召唤的「迅捷鼯鼠」卡片组
	local g=Duel.GetMatchingGroup(c22567609.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检查卡组中是否存在可特召的「迅捷鼯鼠」，并询问己方是否要特殊召唤
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22567609,1)) then  --"是否要特殊召唤？"
		-- 中断效果处理，使后续的特殊召唤与前面的回复基本分视为不同时处理
		Duel.BreakEffect()
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选出的「迅捷鼯鼠」以里侧守备表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方展示里侧特殊召唤的「迅捷鼯鼠」以确认卡名合法
		Duel.ConfirmCards(1-tp,sg)
	end
end
