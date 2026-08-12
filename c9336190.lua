--幻影騎士団ミストクロウズ
-- 效果：
-- ①：以除外的1只自己的「幻影骑士团」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，对方的直接攻击宣言时以自己墓地1只4星以下的「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤，这张卡变成持有和那只怪兽相同原本等级的通常怪兽（战士族·暗·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c9336190.initial_effect(c)
	-- ①：以除外的1只自己的「幻影骑士团」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9336190.target)
	e1:SetOperation(c9336190.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方的直接攻击宣言时以自己墓地1只4星以下的「幻影骑士团」怪兽为对象才能发动。那只怪兽特殊召唤，这张卡变成持有和那只怪兽相同原本等级的通常怪兽（战士族·暗·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9336190,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c9336190.spcon)
	e2:SetTarget(c9336190.sptg)
	e2:SetOperation(c9336190.spop)
	c:RegisterEffect(e2)
end
-- 过滤除外状态的表侧表示「幻影骑士团」怪兽
function c9336190.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择
function c9336190.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c9336190.filter(chkc) end
	-- 检查除外区是否存在符合条件的「幻影骑士团」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9336190.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只除外的「幻影骑士团」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9336190.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理：将作为对象的怪兽加入手牌
function c9336190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果②的发动条件判定
function c9336190.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方怪兽进行直接攻击
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤墓地中可以特殊召唤的4星以下「幻影骑士团」怪兽，并检查自身是否能作为陷阱怪兽特殊召唤
function c9336190.spfilter(c,e,tp)
	return c:IsSetCard(0x10db) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家是否能将这张卡作为特定等级、种族、属性的通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9336190,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,c:GetLevel(),RACE_WARRIOR,ATTRIBUTE_DARK)
end
-- 效果②的发动准备与目标选择
function c9336190.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c9336190.spfilter(chkc,e,tp) end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否有2个以上的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否能进行2次特殊召唤
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查墓地是否存在符合条件的4星以下「幻影骑士团」怪兽
		and Duel.IsExistingTarget(c9336190.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只4星以下的「幻影骑士团」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9336190.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 设置效果处理信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果②的处理：特殊召唤墓地怪兽，并将自身作为通常怪兽特殊召唤
function c9336190.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 特殊召唤作为对象的墓地怪兽
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有空位且这张卡仍符合条件
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 再次确认是否能将这张卡作为通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9336190,0x10db,TYPES_NORMAL_TRAP_MONSTER,0,0,tc:GetLevel(),RACE_WARRIOR,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_NORMAL,0,0,tc:GetLevel(),0,0)
		-- 开始特殊召唤这张卡（作为通常怪兽）的步骤
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		-- 这张卡变成持有和那只怪兽相同原本等级的通常怪兽（战士族·暗·攻/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(tc:GetLevel())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		c:RegisterEffect(e2,true)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
