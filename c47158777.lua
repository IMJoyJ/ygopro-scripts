--破壊剣士の守護絆竜
-- 效果：
-- 怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「破坏剑」卡送去墓地。那之后，可以从手卡把1只「破坏之剑士」怪兽特殊召唤。
-- ②：对方场上没有怪兽存在的自己战斗阶段结束时，以这个回合没有攻击宣言的自己场上1只「破坏之剑士」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
function c47158777.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，需要2个连接素材
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「破坏剑」卡送去墓地。那之后，可以从手卡把1只「破坏之剑士」怪兽特殊召唤。
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
	-- ②：对方场上没有怪兽存在的自己战斗阶段结束时，以这个回合没有攻击宣言的自己场上1只「破坏之剑士」怪兽为对象才能发动。给与对方那只怪兽的攻击力数值的伤害。
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
-- 效果条件：确认此卡是否为连接召唤成功
function c47158777.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：检索满足条件的「破坏剑」卡（可送去墓地）
function c47158777.tgfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGrave()
end
-- 效果目标设置：检查是否有满足条件的「破坏剑」卡存在于卡组
function c47158777.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「破坏剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c47158777.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要送去墓地的卡数量设为1
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：检索满足条件的「破坏之剑士」怪兽（可特殊召唤）
function c47158777.spfilter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：选择1张「破坏剑」卡送去墓地，若成功则询问是否特殊召唤「破坏之剑士」怪兽
function c47158777.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张「破坏剑」卡
	local g=Duel.SelectMatchingCard(tp,c47158777.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认选择的卡已成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查手牌是否有「破坏之剑士」怪兽且场上存在召唤空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c47158777.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否特殊召唤「破坏之剑士」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(47158777,2)) then  --"是否特殊召唤「破坏之剑士」怪兽？"
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只「破坏之剑士」怪兽
		local sg=Duel.SelectMatchingCard(tp,c47158777.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选定的「破坏之剑士」怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检索满足条件的「破坏之剑士」怪兽（表侧表示且未攻击过）
function c47158777.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7) and c:GetAttackAnnouncedCount()==0 and c:GetAttack()>0
end
-- 效果条件：确认当前为己方回合且对方场上无怪兽
function c47158777.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为己方回合且对方场上无怪兽
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=0
end
-- 效果目标设置：选择满足条件的「破坏之剑士」怪兽作为对象
function c47158777.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47158777.damfilter(chkc) end
	-- 检查是否存在满足条件的「破坏之剑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c47158777.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的「破坏之剑士」怪兽
	local g=Duel.SelectTarget(tp,c47158777.damfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将要造成伤害的数值设为该怪兽攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
-- 效果处理：对选定的「破坏之剑士」怪兽造成其攻击力数值的伤害
function c47158777.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给与对方玩家该怪兽攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end
