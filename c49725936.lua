--スリーバーストショット・ドラゴン
-- 效果：
-- 衍生物以外的怪兽2只以上
-- ①：1回合1次，伤害步骤有怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：把这张卡解放，以自己墓地1只连接2以下的怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从手卡把1只4星以下的龙族怪兽特殊召唤。这个效果在这张卡特殊召唤的回合不能发动。
function c49725936.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求连接素材不能是衍生物，最少需要2个
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
-- 判断是否在伤害步骤或伤害计算阶段，并且此卡未在战斗中被破坏，同时发动的卡是怪兽效果或魔法/陷阱卡，且该连锁可以被无效
function c49725936.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断发动的卡是否为怪兽效果或魔法/陷阱卡类型，并检查该连锁是否可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理时的操作信息，指定将要使发动无效
function c49725936.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息中要处理的卡为发动的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行连锁无效操作
function c49725936.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
-- 判断此卡是否在特殊召唤的回合
function c49725936.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
-- 检查是否可以解放此卡作为费用
function c49725936.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为效果的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选满足条件的连接怪兽（连接值不超过2）并可特殊召唤
function c49725936.spfilter1(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选满足条件的龙族怪兽（等级不超过4）并可特殊召唤
function c49725936.spfilter2(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标时的过滤条件，用于从墓地选择符合条件的连接怪兽
function c49725936.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c49725936.spfilter1(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域可以进行特殊召唤
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 确认场上是否存在满足条件的墓地连接怪兽作为目标
		and Duel.IsExistingTarget(c49725936.spfilter1,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡片，即从墓地中选择一只符合条件的连接怪兽
	local g=Duel.SelectTarget(tp,c49725936.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息中要处理的卡为所选的连接怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并在成功后询问是否再特殊召唤手牌中的龙族怪兽
function c49725936.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否存在且能被特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查是否有足够的怪兽区域进行后续的特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取满足条件的手牌龙族怪兽组
		local g=Duel.GetMatchingGroup(c49725936.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		-- 判断是否选择特殊召唤手牌中的龙族怪兽
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(49725936,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使之后的效果视为错时点处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选定的手牌龙族怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
