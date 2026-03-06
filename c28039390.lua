--デストーイ・リニッチ
-- 效果：
-- ①：以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以除外的1只自己的「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽回到墓地。这个效果在这张卡送去墓地的回合不能发动。
function c28039390.initial_effect(c)
	-- 效果原文：①：以自己墓地1只「魔玩具」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28039390,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28039390.target)
	e1:SetOperation(c28039390.activate)
	c:RegisterEffect(e1)
	-- 效果原文：②：把墓地的这张卡除外，以除外的1只自己的「毛绒动物」怪兽或者「魔玩具」怪兽为对象才能发动。那只怪兽回到墓地。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28039390,1))  --"回到墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 规则层面：设置效果条件，使此效果在卡片送去墓地的回合无法发动
	e2:SetCondition(aux.exccon)
	-- 规则层面：设置效果费用，将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28039390.tgtg)
	e2:SetOperation(c28039390.tgop)
	c:RegisterEffect(e2)
end
-- 规则层面：定义过滤函数，用于筛选满足条件的「魔玩具」怪兽
function c28039390.filter(c,e,tp)
	return c:IsSetCard(0xad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：设置效果目标选择函数，判断目标是否为己方墓地的「魔玩具」怪兽
function c28039390.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28039390.filter(chkc,e,tp) end
	-- 规则层面：判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断己方墓地是否存在符合条件的「魔玩具」怪兽
		and Duel.IsExistingTarget(c28039390.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c28039390.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面：设置效果处理信息，表明将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面：执行效果，将选定的怪兽特殊召唤到场上
function c28039390.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面：定义过滤函数，用于筛选满足条件的「毛绒动物」或「魔玩具」怪兽
function c28039390.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa9,0xad) and c:IsType(TYPE_MONSTER)
end
-- 规则层面：设置效果目标选择函数，判断目标是否为除外区的「毛绒动物」或「魔玩具」怪兽
function c28039390.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c28039390.tgfilter(chkc) end
	-- 规则层面：判断己方除外区是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c28039390.tgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 规则层面：向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面：选择符合条件的除外怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c28039390.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 规则层面：设置效果处理信息，表明将怪兽送回墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,1,0,0)
end
-- 规则层面：执行效果，将选定的怪兽送回墓地
function c28039390.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标怪兽以效果和回到墓地的原因送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
