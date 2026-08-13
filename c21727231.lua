--セリオンズ“リーパー”ファム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者水族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：对方回合，以自己的魔法与陷阱区域1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 初始化并注册这张卡的全部效果：①效果（从手卡特召自身并装备墓地怪兽）、②效果（对方回合二速回手）、③效果（作为装备时给装备怪兽提升攻击力并授予②效果）。
function c21727231.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者水族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21727231,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21727231)
	e1:SetTarget(c21727231.sptg)
	e1:SetOperation(c21727231.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己的魔法与陷阱区域1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21727231,1))  --"双方卡回到手卡（兽带斗神“跃鱼”霹雳一）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,21727231+o)
	e2:SetCondition(c21727231.thcon)
	e2:SetTarget(c21727231.thtg)
	e2:SetOperation(c21727231.thop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。此处对应“得到这个卡名的②的效果”的授予部分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c21727231.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c21727231.atkcon)
	c:RegisterEffect(e4)
end
-- 过滤可作为①对象/装备的墓地怪兽：必须是「兽带斗神」怪兽或水族怪兽，且是怪兽卡，且自己场上不存在同名卡（满足同名卡限制）。
function c21727231.eqfilter(c,tp)
	return (c:IsRace(RACE_AQUA) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动阶段：检查自身可特殊召唤、怪兽区和魔陷区有空位、墓地有符合条件对象；若满足则让玩家从自己墓地选择1只符合条件的怪兽作为对象。
function c21727231.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c21727231.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 发动条件之一：确认自己的主要怪兽区和魔法与陷阱区域都有空位（分别用于特殊召唤这张卡与后续装备对象）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之一：确认自己墓地存在至少1只满足eqfilter的「兽带斗神」怪兽或水族怪兽。
		and Duel.IsExistingTarget(c21727231.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向操作玩家显示“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1只满足eqfilter的怪兽作为效果对象（同时将此卡设为连锁对象）。
	local sg=Duel.SelectTarget(tp,c21727231.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：所选择的墓地的卡将离开墓地（CATEGORY_LEAVE_GRAVE），用于相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息：这张卡将被特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：从手卡特殊召唤这张卡；特殊召唤成功后，将对象怪兽作为装备卡装备给这张卡，并给该对象怪兽附加只能装备给这张卡的装备限制。
function c21727231.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认：怪兽区仍有空位且这张卡仍与效果关联（没有被无效或离场），才继续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡以表侧表示特殊召唤；若特殊召唤成功（返回值不为0），继续后续装备处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得①效果发动时选择的那只墓地怪兽。
		local tc=Duel.GetFirstTarget()
		-- 确认该对象仍与效果关联且自己魔陷区有空位，才可以把对象作为装备卡装备。
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将对象怪兽作为装备卡装备给这张卡（up=false保持其原表示形式）。
			Duel.Equip(tp,tc,c,false)
			-- 作为对象的怪兽当作装备卡使用给这张卡装备（附加装备对象限制，使该怪兽只能装备给这张卡）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c21727231.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制条件：装备怪兽只能装备给效果的所有者（即这张卡本体）。
function c21727231.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件判定：仅在对方回合可以发动。
function c21727231.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是对方的回合（tp为效果发动者，1-tp为对方），满足“对方回合”条件。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤可作为②对象之一的自己魔陷区的「兽带斗神」卡：必须表侧表示、位于主要魔陷区（sequence<5，不包括场地格）、且能被返回手卡。
function c21727231.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x179) and c:GetSequence()<5 and c:IsAbleToHand()
end
-- ②效果发动阶段：必须同时选择自己魔陷区1张「兽带斗神」卡和对方场上1张卡；先检查两者都存在合法目标，再依次选择。
function c21727231.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 合法性检查：自己魔陷区存在至少1张满足filter的「兽带斗神」卡。
	if chk==0 then return Duel.IsExistingTarget(c21727231.filter,tp,LOCATION_SZONE,0,1,nil)
		-- 合法性检查：对方场上存在至少1张能被返回手卡的卡。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示本方发动了②效果（显示效果描述文本）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向操作玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己魔法与陷阱区域1张符合条件的「兽带斗神」卡作为对象。
	local g1=Duel.SelectTarget(tp,c21727231.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 再次显示“请选择要返回手牌的卡”的选择提示，用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以被返回手卡的卡作为对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：两张对象卡合计返回持有者手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果处理：从连锁信息中取出对象卡，过滤掉已与效果失去关联的卡，将剩余卡返回持有者手卡。
function c21727231.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡组（自己魔陷区1张+对方场上1张）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍与效果关联的对象卡返回持有者手卡（REASON_EFFECT为效果原因）。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 授予目标过滤：只有装备了这张卡的「兽带斗神」怪兽才能获得②效果（即这张卡作为装备时，e2被授予给装备怪兽）。
function c21727231.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 攻击力上升的适用条件：这张卡当前作为装备卡，且装备对象是「兽带斗神」怪兽。
function c21727231.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
