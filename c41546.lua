--DD魔導賢者トーマス
-- 效果：
-- ←6 【灵摆】 6→
-- 「DD 魔导贤者 托马斯」的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 「DD 魔导贤者 托马斯」的怪兽效果1回合只能使用1次。
-- ①：以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只8星「DDD」怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果无效化，对方受到的战斗伤害变成一半。
function c41546.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（可进行灵摆召唤、灵摆卡发动等），使后续灵摆效果能够注册和生效。
	aux.EnablePendulumAttribute(c)
	-- 「DD 魔导贤者 托马斯」的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41546,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,41546)
	e1:SetTarget(c41546.thtg)
	e1:SetOperation(c41546.thop)
	c:RegisterEffect(e1)
	-- 「DD 魔导贤者 托马斯」的怪兽效果1回合只能使用1次。①：以自己的灵摆区域1张「DD」卡为对象才能发动。那张卡破坏，从卡组把1只8星「DDD」怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果无效化，对方受到的战斗伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41546,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41547)
	e2:SetTarget(c41546.destg)
	e2:SetOperation(c41546.desop)
	c:RegisterEffect(e2)
end
-- 判断额外卡组的卡是否为表侧表示、属于「DD」字段、灵摆怪兽且能被加入手卡的过滤器。
function c41546.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 灵摆效果的发动条件：自己主要阶段且额外卡组存在符合条件的表侧表示「DD」灵摆怪兽时才能发动；并设置把1张卡加入手卡的操作信息。
function c41546.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1张满足 c41546.thfilter 条件的表侧表示「DD」灵摆怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c41546.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 向系统登记本次操作包含‘把卡加入手卡’，且处理时从自己的额外卡组选取1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时，从额外卡组选择1只表侧表示「DD」灵摆怪兽加入手卡，并让对方确认那张卡。
function c41546.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择1张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组中筛选并选择1张符合条件的表侧表示「DD」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c41546.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断卡是否为「DD」字段，用于选择灵摆区要破坏的对象。
function c41546.desfilter(c)
	return c:IsSetCard(0xaf)
end
-- 判断卡组中的卡是否为8星「DDD」怪兽，且能以表侧守备表示被特殊召唤。
function c41546.spfilter(c,e,tp)
	return c:IsSetCard(0x10af) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 怪兽效果的发动条件：取自己灵摆区1张「DD」卡为对象，且自己场上存在可用怪兽区、卡组存在可特殊召唤的8星「DDD」怪兽才能发动；同时登记破坏和特殊召唤的操作信息。
function c41546.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c41546.desfilter(chkc) end
	-- 检查自己灵摆区是否存在至少1张「DD」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c41546.desfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 检查自己场上是否有空闲的主要怪兽区用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在至少1只满足条件的8星「DDD」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c41546.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 弹出选择提示，要求玩家选择1张要破坏的灵摆区「DD」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己灵摆区1张「DD」卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c41546.desfilter,tp,LOCATION_PZONE,0,1,1,nil)
	-- 向系统登记本次操作包含‘破坏’，对象为选中的灵摆区卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向系统登记本次操作包含‘特殊召唤’，处理时从自己的卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，先破坏对象卡；若破坏成功，从卡组选择1只8星「DDD」怪兽以表侧守备表示特殊召唤，并使其效果无效化，最后设置对方受到的战斗伤害变为一半的效果。
function c41546.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联后，将其破坏；若破坏成功则继续后续特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 若自己场上没有可用怪兽区，则中止特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出选择提示，要求玩家选择1只要特殊召唤的8星「DDD」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的8星「DDD」怪兽准备特殊召唤。
		local g=Duel.SelectMatchingCard(tp,c41546.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 以表侧守备表示将选中的怪兽特殊召唤（分步召唤第一步）。若成功，则给它附加效果无效化的效果。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个回合，这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 这个回合，这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 完成这一组特殊召唤的最终处理，使特殊召唤成功生效。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，对方受到的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetValue(HALF_DAMAGE)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘对方受到的战斗伤害减半’的持续效果注册到场上，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
