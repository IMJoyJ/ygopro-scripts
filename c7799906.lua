--EMスマイル・マジシャン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：持有比原本攻击力高的攻击力的自己场上的怪兽被战斗·效果破坏的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「笑容」魔法·陷阱卡加入手卡。
-- ②：自己场上的怪兽只有「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽，这张卡的攻击力比原本攻击力高的场合才能发动。自己从卡组抽出持有比原本攻击力高的攻击力的自己场上的怪兽的数量。这个回合，自己不能把怪兽特殊召唤。
function c7799906.initial_effect(c)
	-- 启用灵摆怪兽的灵摆辅助效果（注册灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：持有比原本攻击力高的攻击力的自己场上的怪兽被战斗·效果破坏的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,7799906)
	e1:SetCondition(c7799906.spcon)
	e1:SetTarget(c7799906.sptg)
	e1:SetOperation(c7799906.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「笑容」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7799906,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,7799907)
	e2:SetTarget(c7799906.thtg)
	e2:SetOperation(c7799906.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上的怪兽只有「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽，这张卡的攻击力比原本攻击力高的场合才能发动。自己从卡组抽出持有比原本攻击力高的攻击力的自己场上的怪兽的数量。这个回合，自己不能把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7799906,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,7799908)
	e4:SetCondition(c7799906.drcon)
	e4:SetTarget(c7799906.drtg)
	e4:SetOperation(c7799906.drop)
	c:RegisterEffect(e4)
end
-- 过滤条件：被战斗或效果破坏、原本控制者是自己、原本在怪兽区域、且在场上的攻击力比原本攻击力高。
function c7799906.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousAttackOnField()>c:GetBaseAttack()
end
-- 灵摆效果发动条件：检查被破坏的卡中是否存在满足上述过滤条件的怪兽。
function c7799906.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7799906.cfilter,1,nil,tp)
end
-- 灵摆效果发动目标：检查自身能否特殊召唤，并设置特殊召唤的操作信息。
function c7799906.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理：将灵摆区域的这张卡特殊召唤。
function c7799906.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡名带有「笑容」的魔法·陷阱卡，且可以加入手牌。
function c7799906.thfilter(c)
	return c:IsSetCard(0x125) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 怪兽效果①发动目标：检查卡组中是否存在可检索的「笑容」魔陷，并设置加入手牌的操作信息。
function c7799906.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「笑容」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c7799906.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，表示从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①处理：从卡组选择1张「笑容」魔法·陷阱卡加入手牌并给对方确认。
function c7799906.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「笑容」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c7799906.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：里侧表示的怪兽，或者不属于「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽的怪兽（用于排除法）。
function c7799906.exfilter(c)
	return c:IsFacedown() or not (c:IsSetCard(0x9f,0x99) or (c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x98)))
end
-- 怪兽效果②发动条件：这张卡的攻击力比原本攻击力高，且自己场上没有不满足条件的怪兽（即自己场上的怪兽只有「娱乐伙伴」怪兽、「魔术师」灵摆怪兽、「异色眼」怪兽）。
function c7799906.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetAttack()>c:GetBaseAttack()
		-- 检查自己场上不存在不属于「娱乐伙伴」、「魔术师」灵摆、「异色眼」的怪兽（即自己场上的怪兽只有这些怪兽）。
		and not Duel.IsExistingMatchingCard(c7799906.exfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示且攻击力比原本攻击力高的怪兽。
function c7799906.drfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 怪兽效果②发动目标：计算自己场上攻击力比原本攻击力高的怪兽数量，检查玩家是否可以抽取该数量的卡，并设置抽卡的操作信息。
function c7799906.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示且攻击力比原本攻击力高的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c7799906.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查玩家是否可以从卡组抽取对应数量的卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置抽卡的操作信息，表示玩家将抽取对应数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 怪兽效果②处理：自己从卡组抽出持有比原本攻击力高的攻击力的自己场上的怪兽的数量，并适用本回合不能特殊召唤的限制。
function c7799906.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己场上表侧表示且攻击力比原本攻击力高的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c7799906.drfilter,tp,LOCATION_MZONE,0,nil)
	-- 玩家因效果从卡组抽取对应数量的卡。
	Duel.Draw(tp,ct,REASON_EFFECT)
	-- 这个回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册全局效果，限制玩家在本回合不能特殊召唤怪兽。
	Duel.RegisterEffect(e1,tp)
end
