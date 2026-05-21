--サイバース・ディセーブルム
-- 效果：
-- 电子界族的仪式·融合·同调·超量·连接怪兽＋电子界族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只电子界族怪兽特殊召唤。那之后，可以把这张卡的等级变成和这个效果特殊召唤的怪兽相同。
-- ②：自己场上有连接4以上的电子界族怪兽存在，对方把魔法·陷阱卡的效果发动时，把场上·墓地的这张卡除外才能发动。那个发动无效。
function c92422871.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为：满足特定过滤条件的怪兽（电子界族仪式/融合/同调/超量/连接怪兽）和1只电子界族怪兽
	aux.AddFusionProcFun2(c,c92422871.matfilter,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),true)
	-- ①：自己主要阶段才能发动。从手卡把1只电子界族怪兽特殊召唤。那之后，可以把这张卡的等级变成和这个效果特殊召唤的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92422871,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,92422871)
	e1:SetTarget(c92422871.sptg)
	e1:SetOperation(c92422871.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有连接4以上的电子界族怪兽存在，对方把魔法·陷阱卡的效果发动时，把场上·墓地的这张卡除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92422871,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,92422872)
	e2:SetCondition(c92422871.negcon)
	-- 将场上·墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c92422871.negtg)
	e2:SetOperation(c92422871.negop)
	c:RegisterEffect(e2)
end
-- 过滤融合素材中第一部分所需的电子界族仪式·融合·同调·超量·连接怪兽
function c92422871.matfilter(c)
	return c:IsFusionType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsRace(RACE_CYBERSE)
end
-- 过滤手卡中可以特殊召唤的电子界族怪兽
function c92422871.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备，检查怪兽区域空位及手卡中是否存在可特召的电子界族怪兽
function c92422871.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特召条件的电子界族怪兽
		and Duel.IsExistingMatchingCard(c92422871.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：从手卡特召1只电子界族怪兽，之后可选择将这张卡的等级变成与特召怪兽相同
function c92422871.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特召条件的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c92422871.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local c=e:GetHandler()
	if #g>0 then
		local tc=g:GetFirst()
		-- 将选择的怪兽表侧表示特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
			and c:IsFaceup() and c:IsRelateToChain()
			and c:GetLevel()>0 and c:GetLevel()~=tc:GetLevel()
			-- 判断自身是否在场且等级与特召怪兽不同，并询问玩家是否改变这张卡的等级
			and Duel.SelectYesNo(tp,aux.Stringid(92422871,2)) then  --"是否改变这张卡的等级？"
			-- 中断当前效果处理，使后续的等级改变处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 可以把这张卡的等级变成和这个效果特殊召唤的怪兽相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 过滤自己场上连接4以上的电子界族怪兽
function c92422871.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsLinkAbove(4)
end
-- 效果②的发动条件，检查自己场上是否存在连接4以上的电子界族怪兽，以及对方是否发动了魔法·陷阱卡的效果
function c92422871.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否存在连接4以上的电子界族怪兽，若不存在则不能发动
	if not Duel.IsExistingMatchingCard(c92422871.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查自身未被战斗破坏、发动者为对方、发动的效果为魔法或陷阱卡的效果，且该发动可以被无效
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 效果②的发动准备，设置无效发动的操作信息
function c92422871.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的效果处理：使该魔法·陷阱卡的效果发动无效
function c92422871.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end
