--影王デュークシェード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是暗属性怪兽不能特殊召唤。
-- ①：把自己场上的暗属性怪兽任意数量解放才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
function c12766474.initial_effect(c)
	-- ①：把自己场上的暗属性怪兽任意数量解放才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力上升解放的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12766474,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12766474)
	e1:SetCost(c12766474.spcost)
	e1:SetTarget(c12766474.sptg)
	e1:SetOperation(c12766474.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只5星以上的暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12766474,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,12766475)
	e2:SetCost(c12766474.thcost)
	e2:SetTarget(c12766474.thtg)
	e2:SetOperation(c12766474.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在该回合中进行的特殊召唤次数，仅对暗属性怪兽有效。
	Duel.AddCustomActivityCounter(12766474,ACTIVITY_SPSUMMON,c12766474.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为暗属性。
function c12766474.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 释放卡片过滤函数，用于判断卡片是否在释放组中。
function c12766474.relfilter(c,g)
	return g:IsContains(c)
end
-- ①效果的费用处理函数，检查是否满足解放条件并执行解放操作。
function c12766474.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上所有可解放的暗属性怪兽组。
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
	-- 检查该回合是否已使用过①效果，且满足解放条件。
	if chk==0 then return Duel.GetCustomActivityCount(12766474,tp,ACTIVITY_SPSUMMON)==0
		-- 检查是否存在满足条件的怪兽组用于解放。
		and rg:CheckSubGroup(aux.mzctcheckrel,1,#rg,tp) end
	-- 创建并注册一个场上的效果，禁止非暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12766474.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上。
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	-- 从符合条件的怪兽组中选择一个子集用于解放。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,1,#rg,tp)
	e:SetLabel(g:GetCount())
	-- 使用额外的解放次数，用于处理特殊召唤时的解放限制。
	aux.UseExtraReleaseCount(g,tp)
	-- 实际执行解放操作。
	Duel.Release(g,REASON_COST)
end
-- 限制非暗属性怪兽特殊召唤的效果函数。
function c12766474.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- ①效果的目标设定函数，检查是否可以特殊召唤此卡。
function c12766474.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理函数，执行特殊召唤并增加攻击力。
function c12766474.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并执行特殊召唤步骤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local ct=e:GetLabel()
		-- 创建一个攻击力提升效果，提升值为解放怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- ②效果的费用处理函数，检查是否已使用过②效果。
function c12766474.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该回合是否已使用过②效果。
	if chk==0 then return Duel.GetCustomActivityCount(12766474,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个场上的效果，禁止非暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12766474.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的目标过滤函数，筛选墓地中的5星以上暗属性怪兽。
function c12766474.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②效果的目标设定函数，选择目标怪兽。
function c12766474.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12766474.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c12766474.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地中选择一只符合条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c12766474.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要将目标怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的发动处理函数，将目标怪兽加入手卡并确认。
function c12766474.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽的卡面。
		Duel.ConfirmCards(1-tp,tc)
	end
end
