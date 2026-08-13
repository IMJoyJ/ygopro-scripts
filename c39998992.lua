--エクスクローラー・シナプシス
-- 效果：
-- 地属性怪兽2只
-- ①：这张卡所连接区的「机怪虫」怪兽不会被战斗破坏，攻击力·守备力上升300，同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
function c39998992.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只地属性怪兽作为连接素材（对应召唤条件“地属性怪兽2只”）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_EARTH),2,2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地2只「机怪虫」怪兽为对象才能发动（同名卡最多1张）。那些怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39998992,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c39998992.spcon)
	e1:SetTarget(c39998992.sptg)
	e1:SetOperation(c39998992.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡所连接区的「机怪虫」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39998992.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	c:RegisterEffect(e5)
end
-- ②效果的发动条件判定：这张卡以表侧表示存在时，因战斗被破坏离场，或因对方控制的效果而从自己场上离开（且离开前控制权属于自己）才满足。
function c39998992.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 筛选可作为第1张对象的墓地「机怪虫」怪兽：必须是「机怪虫」、可以被特殊召唤为里侧守备表示，且墓地还存在另一只卡名不同且符合条件的「机怪虫」怪兽作为第2张对象。
function c39998992.spfilter1(c,e,tp)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确认墓地还存在另一只卡名不同且符合第2张对象条件的「机怪虫」怪兽，以满足“同名卡最多1张”的选择限制。
		and Duel.IsExistingTarget(c39998992.spfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode(),e,tp)
end
-- 筛选可作为第2张对象的墓地「机怪虫」怪兽：卡名与第1张不同、是「机怪虫」、且可以被特殊召唤为里侧守备表示。
function c39998992.spfilter2(c,cd,e,tp)
	return not c:IsCode(cd) and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果发动时的目标选择处理：确认自己不受青眼精灵龙禁止同时特殊召唤2只以上怪兽的效果影响，且自己怪兽区有至少2个空位，墓地存在可选的2只不同名「机怪虫」怪兽后，选择这2只作为效果对象。
function c39998992.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求自己场上的可用怪兽区域数量大于1，确保有足够格子特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己墓地是否存在至少1张可作为第1张对象的「机怪虫」怪兽（其选择后仍能从剩余墓地选出第2张不同名的对象）。
		and Duel.IsExistingTarget(c39998992.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，让玩家进行对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择第1张符合条件的「机怪虫」怪兽，并将其设为该连锁的效果对象。
	local g1=Duel.SelectTarget(tp,c39998992.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	-- 弹出“请选择要特殊召唤的卡”的选择提示，让玩家选择第2张对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择第2张符合条件的「机怪虫」怪兽，且自动排除与第1张卡名相同的卡，满足同名卡最多1张的限制。
	local g2=Duel.SelectTarget(tp,c39998992.spfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:GetCode(),e,tp)
	g1:Merge(g2)
	-- 登记本次连锁的操作为将2只怪兽特殊召唤，供其他卡的效果检测（如青眼精灵龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- ②效果处理：根据对象卡是否仍与效果关联以及可用怪兽区域数决定实际处理；若自己场上空位不足则只能选择空位数量的卡；若青眼精灵龙效果适用且对象多于1只则不处理；最终将对象里的「机怪虫」怪兽以里侧守备表示特殊召唤，并向对方展示这些卡。
function c39998992.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区可用空格数量，用于判断能否特殊召唤及实际召唤数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取该连锁发动时选择的对象卡组（2只「机怪虫」墓地怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 弹出“请选择要特殊召唤的卡”的选择提示，用于空位不足时让玩家选择实际要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	if g:GetCount()>0 then
		-- 将选出的「机怪虫」怪兽以里侧守备表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认特殊召唤的里侧守备怪兽，展示这些卡的卡名信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ①效果的对象判定：要保护的怪兽必须位于这张卡的连接区内，且属于「机怪虫」系列（0x104），才受到该效果的保护。
function c39998992.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x104)
end
