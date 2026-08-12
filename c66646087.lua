--超量妖精ゼータン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上有「超级量子妖精 泽坦」以外的「超级量子」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以把这张卡的等级变成和自己场上1只「超级量子」怪兽相同。
-- ②：把这张卡解放，从卡组把暗属性怪兽以外的1张「超级量子」卡送去墓地才能发动。从卡组把「超级量子妖精 泽坦」以外的1只「超级量子」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特殊召唤及改变等级）和②效果（解放自身并送墓卡组卡片来特殊召唤卡组怪兽）
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上有「超级量子妖精 泽坦」以外的「超级量子」怪兽存在的场合才能发动。这张卡特殊召唤。那之后，可以把这张卡的等级变成和自己场上1只「超级量子」怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，从卡组把暗属性怪兽以外的1张「超级量子」卡送去墓地才能发动。从卡组把「超级量子妖精 泽坦」以外的1只「超级量子」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示存在的「超级量子妖精 泽坦」以外的「超级量子」怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsCode(id) and c:IsSetCard(0xdc)
end
-- ①效果的发动条件：自己场上存在「超级量子妖精 泽坦」以外的「超级量子」怪兽
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件（表侧表示且非同名的「超级量子」怪兽）的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备与合法性检查（检查怪兽区域空位及自身是否能特殊召唤）
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：自己场上表侧表示存在、等级在1以上且与当前自身等级不同的「超级量子」怪兽
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xdc) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- ①效果的处理：特殊召唤自身，之后可以任选自己场上1只「超级量子」怪兽，将自身的等级变成与其相同
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关，并成功将此卡以表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查自己场上是否存在等级与自身当前等级不同的「超级量子」怪兽
		and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
		-- 询问玩家是否选择发动后续的“改变等级”效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变等级？"
		-- 提示玩家选择作为等级参考的目标怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 玩家选择1只自己场上的「超级量子」怪兽
		local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,c:GetLevel())
		-- 中断当前效果处理，使后续的等级改变处理与特殊召唤不视为同时进行（错时点）
		Duel.BreakEffect()
		-- 显式地在场上框选并展示所选择的怪兽
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		-- 可以把这张卡的等级变成和自己场上1只「超级量子」怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件（用于cost送墓）：卡组中暗属性以外的「超级量子」卡，且该卡能作为代价送去墓地，并且此时卡组中还存在其他可特殊召唤的「超级量子」怪兽
function s.cfilter1(c,e,tp)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(0xdc) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在除送墓卡以外的、可特殊召唤的「超级量子」怪兽（确保送墓后仍有合法特召对象）
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,e,tp)
end
-- ②效果的发动代价处理：解放自身，并将卡组中暗属性以外的1张「超级量子」卡送去墓地
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否可以解放，以及卡组中是否存在满足送墓条件的卡（用于判断是否能支付发动代价）
	if chk==0 then return e:GetHandler():IsReleasable() and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张暗属性以外的「超级量子」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的卡送去墓地作为发动的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中「超级量子妖精 泽坦」以外的、可以特殊召唤的「超级量子」怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xdc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与合法性检查（检查解放自身后可用的怪兽区域空位，以及卡组中是否有可特殊召唤的怪兽）
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡解放离开场上后，自己场上是否有可用的怪兽区域空位（用于判断是否能进行特殊召唤）
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在满足特殊召唤条件的「超级量子」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1只「超级量子妖精 泽坦」以外的「超级量子」怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只「超级量子妖精 泽坦」以外的「超级量子」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
