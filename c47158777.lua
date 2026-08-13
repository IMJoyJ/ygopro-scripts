--破壊剣士の守護絆竜
-- 效果：
-- 怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「破坏剑」卡送去墓地。那之后，可以从手卡把1只「破坏之剑士」怪兽特殊召唤。
-- ②：对方场上没有怪兽存在的自己战斗阶段结束时，以这个回合没有攻击宣言的自己场上1只「破坏之剑士」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
function c47158777.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只任意怪兽作为连接素材（对应效果原文的“怪兽2只”）。
	aux.AddLinkProcedure(c,nil,2,2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤成功的场合才能发动。从卡组把1张「破坏剑」卡送去墓地。那之后，可以从手卡把1只「破坏之剑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47158777,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,47158777)
	e1:SetCondition(c47158777.tgcon)
	e1:SetTarget(c47158777.tgtg)
	e1:SetOperation(c47158777.tgop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方场上没有怪兽存在的自己战斗阶段结束时，以这个回合没有攻击宣言的自己场上1只「破坏之剑士」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47158777,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,47158778)
	e2:SetCondition(c47158777.damcon)
	e2:SetTarget(c47158777.damtg)
	e2:SetOperation(c47158777.damop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：判定这张卡是否以连接召唤方式特殊召唤成功。
function c47158777.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 从卡组选择送去墓地的卡的过滤条件：持有「破坏剑」字段且可以被送去墓地。
function c47158777.tgfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGrave()
end
-- ①效果的发动时处理：确认卡组中存在符合条件的「破坏剑」卡，并登记将其送去墓地的操作信息。
function c47158777.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中存在至少1张满足条件的「破坏剑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c47158777.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果处理将把1张卡从卡组送去墓地的操作信息（用于时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤的过滤条件：手卡的「破坏之剑士」怪兽且能够被效果特殊召唤。
function c47158777.spfilter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的实际处理：从卡组选择1张「破坏剑」卡送去墓地，之后可选择手卡1只「破坏之剑士」怪兽特殊召唤。
function c47158777.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的「破坏剑」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选出1张满足条件的「破坏剑」卡送去墓地。
	local g=Duel.SelectMatchingCard(tp,c47158777.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认送墓成功且该卡已在墓地中，才继续后续特殊召唤判断。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 额外判断自己场上有可用怪兽区，且手卡存在可特殊召唤的「破坏之剑士」怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c47158777.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否发动“那之后”的特殊召唤效果。
		and Duel.SelectYesNo(tp,aux.Stringid(47158777,2)) then  --"是否特殊召唤「破坏之剑士」怪兽？"
		-- 中断当前效果处理，使后续特殊召唤视为另一次处理，避免错过时点。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的「破坏之剑士」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只符合条件的「破坏之剑士」怪兽。
		local sg=Duel.SelectMatchingCard(tp,c47158777.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果对象筛选：表侧表示的「破坏之剑士」怪兽，本回合未进行过攻击宣言，且攻击力大于0。
function c47158777.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7) and c:GetAttackAnnouncedCount()==0 and c:GetAttack()>0
end
-- ②效果发动条件：当前为已方战斗阶段结束时，且对方场上没有怪兽。
function c47158777.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为己方战斗阶段结束且对方场上无怪兽。
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=0
end
-- ②效果的目标处理：选择自己场上1只符合条件的「破坏之剑士」怪兽作为对象，并登记造成伤害。
function c47158777.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47158777.damfilter(chkc) end
	-- 效果发动合法性检查：自己场上存在1只满足条件的「破坏之剑士」怪兽可被选择。
	if chk==0 then return Duel.IsExistingTarget(c47158777.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要作为伤害对象的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「破坏之剑士」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c47158777.damfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记效果处理信息：将对对方造成所选怪兽攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- ②效果处理：若对象仍与效果关联且表侧表示，给与对方该怪兽攻击力数值的伤害。
function c47158777.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给与对方那只怪兽当前攻击力数值的效果伤害。
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end
