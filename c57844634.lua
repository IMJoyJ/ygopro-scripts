--素早いムササビ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。并且可以再从自己卡组把「迅捷飞鼠」任意数量在对方场上表侧攻击表示特殊召唤。这张卡不能为上级召唤而解放。
function c57844634.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，给与对方基本分500分伤害。并且可以再从自己卡组把「迅捷飞鼠」任意数量在对方场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57844634,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c57844634.condition)
	e1:SetTarget(c57844634.target)
	e1:SetOperation(c57844634.operation)
	c:RegisterEffect(e1)
	-- 这张卡不能为上级召唤而解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 检查此卡是否因战斗破坏而送去墓地
function c57844634.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标确认，设置给与对方伤害的操作信息
function c57844634.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置给与对方玩家500点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤卡组中卡名为「迅捷飞鼠」且能以表侧攻击表示特殊召唤到对方场上的卡
function c57844634.filter(c,e,tp)
	return c:IsCode(57844634) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp)
end
-- 效果处理：给与对方500点伤害，并可选择是否从卡组将任意数量的「迅捷飞鼠」特殊召唤到对方场上
function c57844634.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上可供自己特殊召唤怪兽的空位数量
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	-- 给与对方玩家500点效果伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己卡组中所有符合特殊召唤条件的「迅捷飞鼠」
	local g=Duel.GetMatchingGroup(c57844634.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若卡组中存在可召唤的卡，询问玩家是否选择特殊召唤
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(57844634,1)) then  --"是否要特殊召唤「迅捷飞鼠」？"
		-- 中断效果处理，使伤害和特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 在系统提示栏显示“请选择要特殊召唤的卡”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选中的卡在对方场上表侧攻击表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
