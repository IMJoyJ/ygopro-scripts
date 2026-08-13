--デストーイ・リニッチ
-- 效果：
-- ①：以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以除外的1只自己的「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽回到墓地。这个效果在这张卡送去墓地的回合不能发动。
function c28039390.initial_effect(c)
	-- ①：以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28039390,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28039390.target)
	e1:SetOperation(c28039390.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的1只自己的「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽回到墓地。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28039390,1))  --"回到墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动（通过aux.exccon判断当前回合是否为其被送去墓地的回合，若是则条件不成立）。
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：将墓地中的这张卡除外（aux.bfgcost检查其能否作为代价除外并执行除外）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28039390.tgtg)
	e2:SetOperation(c28039390.tgop)
	c:RegisterEffect(e2)
end
-- 定义效果①可特殊召唤的怪兽筛选条件：持有「魔玩具」（0xad）字段，且满足当前效果特殊召唤的召唤条件与苏生限制。
function c28039390.filter(c,e,tp)
	return c:IsSetCard(0xad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动/选对象阶段：若检查已选对象，则验证其为自己墓地且满足filter；若为发动合法性检查，则确认墓地存在可特殊召唤的目标且自己有怪兽区空格。
function c28039390.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28039390.filter(chkc,e,tp) end
	-- 在效果①发动条件检查中，确认自己主要怪兽区域存在空格，以保证能够特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在效果①发动条件检查中，确认自己墓地存在至少1只满足filter且能成为效果对象的「魔玩具」怪兽。
		and Duel.IsExistingTarget(c28039390.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示提示“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON），用于选择特殊召唤对象的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足filter的「魔玩具」怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28039390.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：表明本效果处理时将进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），供其他效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理时的实际执行：取得对象怪兽，若其仍与效果相关，则将其特殊召唤。
function c28039390.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②的对象筛选条件：表侧表示且属于「毛绒动物」（0xa9）或「魔玩具」（0xad）字段的怪兽卡。
function c28039390.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9,0xad) and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动/选对象阶段：验证并选择除外区自己的表侧「毛绒动物」或「魔玩具」怪兽作为对象，并设置操作信息。
function c28039390.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c28039390.tgfilter(chkc) end
	-- 在效果②发动条件检查中，确认除外区存在至少1只满足filter且能成为效果对象的自己的表侧「毛绒动物」或「魔玩具」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28039390.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示提示“请选择要送去墓地的卡”（HINTMSG_TOGRAVE），用于选择对象的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从除外区选择1只满足filter的自己的怪兽作为效果对象，并登记为当前连锁的对象。
	local sg=Duel.SelectTarget(tp,c28039390.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息：表明本效果处理时将把1只对象怪兽送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
end
-- 效果②处理时的实际执行：取得对象怪兽，若其仍与效果相关，则将其从除外区送去墓地。
function c28039390.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽从除外区送去墓地，送入原因标记为效果（REASON_EFFECT）并带有“回到墓地”（REASON_RETURN）的语义。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
