--ジャイアントウィルス
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。给与对方500伤害。那之后，可以从卡组把「巨型病毒」任意数量攻击表示特殊召唤。
function c95178994.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。给与对方500伤害。那之后，可以从卡组把「巨型病毒」任意数量攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95178994,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c95178994.condition)
	e1:SetTarget(c95178994.target)
	e1:SetOperation(c95178994.operation)
	c:RegisterEffect(e1)
end
-- 确认这张卡是否在墓地且是被战斗破坏送去墓地的
function c95178994.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动的目标确认与操作信息注册
function c95178994.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤卡组中卡名为「巨型病毒」且可以表侧攻击表示特殊召唤的怪兽
function c95178994.filter(c,e,tp)
	return c:IsCode(95178994) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理：给与对方500伤害，之后可以从卡组把「巨型病毒」任意数量攻击表示特殊召唤
function c95178994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 给与对方500点效果伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有符合条件的「巨型病毒」
	local g=Duel.GetMatchingGroup(c95178994.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若卡组中存在符合条件的卡，则由玩家选择是否发动后续的特殊召唤效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(95178994,1)) then  --"是否要特殊召唤？"
		-- 中断效果处理，使伤害和特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
