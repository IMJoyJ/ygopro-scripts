--メタルフォーゼ・バニッシャー
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的怪兽被效果破坏的场合才能发动。从自己墓地选「炼装勇士·消灭」以外的1张「炼装」卡加入手卡。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：以包含「炼装」卡的自己场上2张表侧表示的卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
-- ②：这张卡用「炼装」卡的效果特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
function c56518311.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己场上的怪兽被效果破坏的场合才能发动。从自己墓地选「炼装勇士·消灭」以外的1张「炼装」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56518311,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,56518311)
	e1:SetCondition(c56518311.condition)
	e1:SetTarget(c56518311.target)
	e1:SetOperation(c56518311.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：以包含「炼装」卡的自己场上2张表侧表示的卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56518311,1))  --"破坏并特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,56518312)
	e2:SetTarget(c56518311.sptg)
	e2:SetOperation(c56518311.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：这张卡用「炼装」卡的效果特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56518311,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,56518313)
	e3:SetCondition(c56518311.rmcon)
	e3:SetTarget(c56518311.rmtg)
	e3:SetOperation(c56518311.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：原本控制者为自己且在怪兽区域的卡因效果被破坏。
function c56518311.desfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 灵摆效果发动条件：自己场上的怪兽被效果破坏。
function c56518311.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c56518311.desfilter,1,nil,tp)
end
-- 过滤条件：墓地中「炼装勇士·消灭」以外的「炼装」卡。
function c56518311.thfilter(c)
	return c:IsSetCard(0xe1) and not c:IsCode(56518311) and c:IsAbleToHand()
end
-- 灵摆效果发动准备：检查墓地是否存在符合条件的卡，并设置回收手卡的操作信息。
function c56518311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张「炼装勇士·消灭」以外的「炼装」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c56518311.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从自己墓地将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 灵摆效果处理：从自己墓地选择1张「炼装勇士·消灭」以外的「炼装」卡加入手卡。
function c56518311.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1张符合条件且不受「王家长眠之谷」影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c56518311.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示且能成为效果对象的卡。
function c56518311.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 组选择条件：选中的卡中包含「炼装」卡，且这些卡离开场上后能空出可用的怪兽区域。
function c56518311.fselect(g,tp)
	-- 检查选中的卡中是否包含「炼装」卡，且这些卡离开场上后自己场上有可用于特殊召唤的怪兽区域。
	return g:IsExists(Card.IsSetCard,1,nil,0xe1) and Duel.GetMZoneCount(tp,g)>0
end
-- 怪兽效果①发动准备：选择自己场上2张表侧表示的卡（包含「炼装」卡）作为对象，并设置破坏和特殊召唤的操作信息。
function c56518311.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有表侧表示且能成为效果对象的卡。
	local g=Duel.GetMatchingGroup(c56518311.filter,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c56518311.fselect,2,2,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,c56518311.fselect,false,2,2,tp)
	-- 将选中的2张卡设为效果的对象。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：破坏选中的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
	-- 设置操作信息：将手卡的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 怪兽效果①处理：破坏作为对象的卡，并从手卡特殊召唤这张卡。
function c56518311.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 尝试破坏这些卡，若成功破坏了至少1张卡则继续执行。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②发动条件：检查这张卡是否是用「炼装」卡的效果特殊召唤成功的。
function c56518311.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0xe1)
end
-- 过滤条件：可以被除外的怪兽。
function c56518311.rmfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 怪兽效果②发动准备：选择对方场上或墓地的一只怪兽作为对象，并设置除外的操作信息。
function c56518311.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c56518311.rmfilter(chkc) end
	-- 检查对方场上或墓地是否存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c56518311.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从场上（其次从墓地）选择对方的1只怪兽作为对象。
	local g=aux.SelectTargetFromFieldFirst(tp,c56518311.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将选中的1只怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 怪兽效果②处理：将作为对象的怪兽除外。
function c56518311.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
