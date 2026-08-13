--拒神ドゥータン
-- 效果：
-- 光属性怪兽＋场上·墓地以外的怪兽×2
-- ①：融合召唤的这张卡不会被战斗破坏。
-- ②：原本卡名和对方的场上·墓地的怪兽相同的怪兽在自己的场上·墓地其中每种之内都不存在的场合，自己场上的怪兽不会被效果破坏。
-- ③：把原本卡名和对方的场上·墓地的怪兽相同的1只怪兽从手卡·卡组·额外卡组送去墓地，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
local s,id,o=GetID()
-- 初始化卡片的全部效果：注册融合召唤手续（光属性怪兽＋场上·墓地以外的怪兽×2）、融合召唤苏生限制，并依次注册①不被战斗破坏、②怪兽不被效果破坏、③送墓除外三个效果。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：融合素材为1只光属性怪兽和2只不在场上·墓地区域的怪兽（即场上·墓地以外的怪兽），使这张卡可通过规定的素材进行融合召唤。
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),aux.FilterBoolFunction(aux.NOT(Card.IsLocation),LOCATION_ONFIELD+LOCATION_GRAVE),2,true)
	c:EnableReviveLimit()
	-- ①：融合召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：原本卡名和对方的场上·墓地的怪兽相同的怪兽在自己的场上·墓地其中每种之内都不存在的场合，自己场上的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(s.indcon2)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：把原本卡名和对方的场上·墓地的怪兽相同的1只怪兽从手卡·卡组·额外卡组送去墓地，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：判断此卡是否为融合召唤方式出场的融合怪兽；只有融合召唤的这张卡才适用不被战斗破坏。
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤函数：从自己场上·墓地中筛选出“原本卡名与对方场上或墓地存在的某只怪兽相同”的怪兽，用于②效果的条件判断。
function s.cfilter(c,tp)
	-- 判断c是否为表侧表示，并检查对方场上·墓地是否存在原本卡名与c相同的怪兽；若存在则该c被筛选出来。
	return c:IsFaceupEx() and Duel.IsExistingMatchingCard(s.codefilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetOriginalCode())
end
-- 过滤函数：判断一张卡是否为表侧表示且为怪兽，并且其原本卡名（以原卡号判断）与指定卡号相同，用于查找同原本卡名的怪兽。
function s.codefilter(c,code)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:GetOriginalCode()==code
end
-- ②效果的适用条件：检查自己场上·墓地中是否存在原本卡名与对方场上·墓地怪兽相同的怪兽；若不存在，则自己场上的怪兽获得不被效果破坏的抗性。
function s.indcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 执行否定判断：在自己场上·墓地中没有找到任何满足s.cfilter的怪兽时返回true，使②效果适用。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
end
-- ③效果代价的过滤函数：从手卡·卡组·额外卡组中选出“原本卡名与对方场上·墓地怪兽相同”且能作为代价送去墓地的1只怪兽。
function s.cfilter1(c,tp)
	-- 判断该怪兽是怪兽，并且对方场上·墓地存在原本卡名与之相同的怪兽，作为代价送墓的资格条件之一。
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.codefilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,c:GetOriginalCode())
		and c:IsAbleToGraveAsCost()
end
-- ③效果的代价处理：先确认存在满足条件的代价怪兽，然后提示玩家从手卡·卡组·额外卡组中选择1只同类原卡名怪兽送去墓地作为发动代价。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡·卡组·额外卡组中是否存在至少1只满足s.cfilter1条件（与对方场上/墓地怪兽同原本卡名且能作代价）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	-- 发送选择卡片提示：弹窗显示‘请选择要送去墓地的卡’，引导玩家选取作为③效果代价的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡·卡组·额外卡组中选择1只满足s.cfilter1条件的怪兽，作为③效果的代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选中的怪兽以REASON_COST（代价）形式送去墓地，完成③效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果取对象的过滤函数：筛选出对方场上·墓地中的怪兽且可以被除外，作为③效果的对象。
function s.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ③效果的目标选择阶段：确认对方场上·墓地存在合法对象，提示玩家选择，并优先从场上选择1只符合条件的怪兽，同时设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 目标合法性检查：确认对方场上·墓地是否存在至少1只可被除外的怪兽，作为③效果的对象。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 发送选择卡片提示：弹窗显示‘请选择要除外的卡’，引导玩家选取③效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对象：从对方场上·墓地中选择1只满足s.rmfilter条件的怪兽作为效果对象；若场上有合法对象则优先从场上选择，不足时才可从墓地选择。
	local g=aux.SelectTargetFromFieldFirst(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁的操作信息：将对1只对象怪兽进行除外处理，供其他卡（如星尘龙）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果处理：取得发动时选择的对象，若对象仍与该效果关联，则将其表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示除外，完成③效果的除外处理。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
