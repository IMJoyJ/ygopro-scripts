--スリーバーストショット・ドラゴン
-- 效果：
-- 衍生物以外的怪兽2只以上
-- ①：1回合1次，伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：把这张卡解放，以自己墓地1只连接2以下的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从手卡把1只4星以下的龙族怪兽特殊召唤。这个效果在这张卡特殊召唤的回合不能发动。
function c49725936.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求使用衍生物以外的怪兽2只以上作为连接素材。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2)
	c:EnableReviveLimit()
	-- ①：1回合1次，伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49725936,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c49725936.negcon)
	e1:SetTarget(c49725936.negtg)
	e1:SetOperation(c49725936.negop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放，以自己墓地1只连接2以下的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从手卡把1只4星以下的龙族怪兽特殊召唤。这个效果在这张卡特殊召唤的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49725936,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,49725936)
	e3:SetCondition(c49725936.spcon)
	e3:SetCost(c49725936.spcost)
	e3:SetTarget(c49725936.sptg)
	e3:SetOperation(c49725936.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断：当前处于伤害步骤或伤害计算时、此卡未被战斗破坏确定、被连锁的效果是怪兽效果或魔法·陷阱卡的发动，且该发动能够被无效。
function c49725936.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于伤害步骤/伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确认被连锁的效果类型为怪兽效果或魔法·陷阱卡发动，且该连锁可以被无效。
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- ①效果的发动目标检查：满足发动条件即可发动（无需选择对象），并登记本次无效的对象信息。
function c49725936.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次无效的对象登记为当前连锁的发动卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果的处理：将对方发动的连锁无效。
function c49725936.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效处理，使指定连锁的发动无效。
	Duel.NegateActivation(ev)
end
-- ③效果的发动条件：这张卡不是在本回合特殊召唤的场合才能发动。
function c49725936.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- ③效果的发动代价：判断这张卡是否可解放，可解放时解放自身作为COST。
function c49725936.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放，作为③效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选③效果对象：墓地的连接怪兽，连接标记在2以下，且可以被特殊召唤。
function c49725936.spfilter1(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选后续特殊召唤的怪兽：手卡的龙族怪兽，等级4以下，且可以被特殊召唤。
function c49725936.spfilter2(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标：从自己墓地选择1只连接2以下的怪兽为对象；发动需要自己场上有可用的怪兽区且墓地存在符合条件的对象。
function c49725936.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49725936.spfilter1(chkc,e,tp) end
	-- 发动条件检查：解放这张卡后自己场上是否存在可用的怪兽区。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 且自己墓地存在1只满足连接2以下、可特殊召唤的怪兽作为对象。
		and Duel.IsExistingTarget(c49725936.spfilter1,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 在选择墓地对象前，给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的连接怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,c49725936.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：对选择的怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：先特殊召唤对象怪兽；若成功且场上还有空位，则玩家可选择再特殊召唤手卡中的1只龙族怪兽。
function c49725936.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与此效果关联，并表侧攻击表示特殊召唤该对象；若特殊召唤成功则继续执行后续逻辑。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 如果自己场上没有可用怪兽区，则无法进行后续从手卡特召，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取手卡中所有满足条件的龙族怪兽（等级4以下且可特殊召唤）的集合。
		local g=Duel.GetMatchingGroup(c49725936.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		-- 如果存在符合条件的龙族怪兽，且玩家选择“是”，则执行追加特殊召唤。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49725936,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，让后续追加特殊召唤作为另一个时点处理，避免与前面的特召同时处理导致错失时点。
			Duel.BreakEffect()
			-- 在追加特召时向玩家显示“请选择要特殊召唤的卡”的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选择的手卡龙族怪兽表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
