--ネオ・カイザー・グライダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只怪兽丢弃，以自己墓地1只龙族通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降500。
function c45885288.initial_effect(c)
	-- 对应①效果：从手卡把这张卡和1只怪兽丢弃，以自己墓地1只龙族通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45885288,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45885288)
	e1:SetCost(c45885288.spcost)
	e1:SetTarget(c45885288.sptg)
	e1:SetOperation(c45885288.spop)
	c:RegisterEffect(e1)
	-- 对应②效果：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45885288,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,45885289)
	e2:SetTarget(c45885288.atktg)
	e2:SetOperation(c45885288.atkop)
	c:RegisterEffect(e2)
end
-- 筛选可作为丢弃代价的怪兽：必须是怪兽卡且满足丢弃条件（可丢弃）。用于①效果从手牌丢弃这张卡和1只怪兽的代价。
function c45885288.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ①效果的发动代价检查：确认这张卡自身可以丢弃，并且手牌中存在另一只可丢弃的怪兽，从而满足“从手卡把这张卡和1只怪兽丢弃”的发动条件。
function c45885288.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 确认手牌中（除自身外）存在至少1只满足丢弃条件的怪兽，作为代价中“1只怪兽”的部分。
		and Duel.IsExistingMatchingCard(c45885288.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示消息，为接下来的选择做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1只怪兽作为丢弃代价（不能选这张卡自身），用于与这张卡一起丢弃。
	local g=Duel.SelectMatchingCard(tp,c45885288.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选出的怪兽和这张卡本身以丢弃并作为代价的理由送去墓地，完成①效果的发动代价。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 筛选可作为特殊召唤对象的墓地龙族通常怪兽：必须是通常怪兽、龙族，且可以被特殊召唤。
function c45885288.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择与合法性检查：需要主要怪兽区有空位，并且墓地中存在1只龙族通常怪兽可以作为效果对象。
function c45885288.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45885288.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空余格子，以确定能否特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足filter条件的龙族通常怪兽，可作为此效果的对象。
		and Duel.IsExistingTarget(c45885288.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，为选择对象做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只龙族通常怪兽作为效果对象（取对象），并建立对象关联。
	local g=Duel.SelectTarget(tp,c45885288.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：本次连锁将进行1只怪兽的特殊召唤，供相关卡牌效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，若它仍与效果关联（未离场等），则将其以表侧表示特殊召唤到己方场上。
function c45885288.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区，不进行苏生限制等额外检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件检查：对方场上有表侧表示怪兽存在时才能发动。
function c45885288.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方场上存在至少1只表侧表示怪兽，以满足“对方场上的全部怪兽”的存在前提。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ②效果处理：选中对方场上所有表侧表示怪兽，给它们各注册一个攻击力下降的效果，直到回合结束时攻击力下降500。
function c45885288.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽，作为攻击力下降的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对应②效果后半句：对方场上的全部怪兽的攻击力直到回合结束时下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
