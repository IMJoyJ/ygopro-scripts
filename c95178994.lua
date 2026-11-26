--ジャイアントウィルス
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。给与对方500伤害。那之后，可以从卡组把「巨型病毒」任意数量攻击表示特殊召唤。
function c95178994.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。给与对方500伤害。那之后，可以从卡组把「巨型病毒」任意数量攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95178994,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c95178994.condition)
	e1:SetTarget(c95178994.target)
	e1:SetOperation(c95178994.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡因战斗破坏送去墓地且当前位于墓地
function c95178994.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 必发效果发动前登记给予对方500点效果伤害的操作信息
function c95178994.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记给予对方500点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 过滤卡组中卡名为「巨型病毒」且可表侧攻击表示特殊召唤的怪兽
function c95178994.filter(c,e,tp)
	return c:IsCode(95178994) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理：先给予对方500点效果伤害，若己方怪兽区有空位（受「青眼精灵龙」限制为1）且卡组有「巨型病毒」，可选择任意数量（1至空位数）攻击表示特殊召唤
function c95178994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在造成伤害前获取己方怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 给予对方500点效果伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 从己方卡组检索所有可表侧攻击表示特殊召唤的「巨型病毒」
	local g=Duel.GetMatchingGroup(c95178994.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若卡组存在可特召的「巨型病毒」，询问己方玩家是否特殊召唤
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(95178994,1)) then  --"是否要特殊召唤？"
		-- 插入效果处理间断，使伤害与后续卡组特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 向己方发送从卡组选择要特殊召唤的「巨型病毒」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,ft,nil)
		-- 将选中的任意数量「巨型病毒」以表侧攻击表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
