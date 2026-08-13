--聖天樹の灰樹精
-- 效果：
-- 包含连接怪兽的植物族怪兽2只以上
-- ①：这张卡连接召唤成功的场合才能发动。从自己墓地选1只「圣种之地灵」特殊召唤。
-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ③：1回合1次，以这张卡所连接区1只自己的「圣蔓」连接怪兽为对象才能发动。这个回合，那只怪兽可以作出最多有自己场上的「圣天树」连接怪兽数量的攻击。
function c44478599.initial_effect(c)
	-- 为这张卡添加连接召唤手续：用2~3只植物族怪兽作为连接素材，且其中必须包含连接怪兽（对应素材条件“包含连接怪兽的植物族怪兽2只以上”）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,3,c44478599.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从自己墓地选1只「圣种之地灵」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44478599,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c44478599.spcon)
	e1:SetTarget(c44478599.sptg)
	e1:SetOperation(c44478599.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以这张卡所连接区1只自己的「圣蔓」连接怪兽为对象才能发动。这个回合，那只怪兽可以作出最多有自己场上的「圣天树」连接怪兽数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44478599,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c44478599.mtcon)
	e3:SetTarget(c44478599.mttg)
	e3:SetOperation(c44478599.mtop)
	c:RegisterEffect(e3)
end
-- 连接素材检查：从所选素材中确认至少存在1只连接怪兽，以满足“包含连接怪兽的植物族怪兽”这一素材条件。
function c44478599.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 效果①的发动条件：这张卡是以连接召唤方式成功特殊召唤（召唤类型为连接召唤）。
function c44478599.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤对象过滤器：必须是卡名「圣种之地灵」（卡号27520594），且满足特殊召唤条件/苏生限制。
function c44478599.spfilter(c,e,tp)
	return c:IsCode(27520594) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动判定：当进行发动合法性检查时，要求自己主要怪兽区有空位，并且墓地存在符合条件的「圣种之地灵」。
function c44478599.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在空余格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在至少1张符合条件的「圣种之地灵」可供特殊召唤。
		and Duel.IsExistingMatchingCard(c44478599.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果为从墓地特殊召唤1只怪兽，用于连锁检测和相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①处理：若仍有空位，则提示玩家从墓地选择1只符合条件的「圣种之地灵」，以表侧表示特殊召唤到自己场上。
function c44478599.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区有空位，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的「圣种之地灵」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c44478599.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「圣种之地灵」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动条件：当前可以进入战斗阶段（即处于主要阶段且未进行过战斗阶段，保证额外攻击次数有意义）。
function c44478599.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否能够进入战斗阶段，作为效果③的起动条件。
	return Duel.IsAbleToEnterBP()
end
-- 效果③的对象过滤器：选择自己场上位于这张卡所连接区（g中包含）的「圣蔓」连接怪兽。
function c44478599.cfilter(c,g)
	return c:IsSetCard(0x1158) and c:IsType(TYPE_LINK) and g:IsContains(c)
end
-- 计数过滤器：统计自己场上表侧表示的「圣天树」系列连接怪兽数量，用于计算攻击次数上限。
function c44478599.valfilter(c)
	return c:IsSetCard(0x2158) and c:IsType(TYPE_LINK)
end
-- 效果③的目标选择与发动判定：要求存在位于连接区的「圣蔓」连接怪兽可作为对象，且自己场上「圣天树」连接怪兽数量大于1（否则额外攻击无意义）。
function c44478599.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c44478599.cfilter(chkc,lg) end
	-- 发动判定：自己场上存在至少1只符合条件的位于连接区的「圣蔓」连接怪兽。
	if chk==0 then return Duel.IsExistingTarget(c44478599.cfilter,tp,LOCATION_MZONE,0,1,nil,lg)
		-- 且自己场上的「圣天树」连接怪兽数量超过1，保证效果能增加攻击次数。
		and Duel.GetMatchingGroupCount(c44478599.valfilter,tp,LOCATION_MZONE,0,nil)>1 end
	-- 显示选择提示，要求玩家选择表侧表示的连接怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的「圣蔓」连接怪兽，并将其设为效果对象（取对象）。
	Duel.SelectTarget(tp,c44478599.cfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
-- 效果③处理：取得对象怪兽，统计场上「圣天树」连接怪兽数量；若数量>1，则给对象额外增加（数量-1）次攻击；若数量为0，则使对象本回合不能攻击。
function c44478599.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象（被选择的「圣蔓」连接怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 统计自己场上当前存在的「圣天树」连接怪兽数量，作为可攻击次数上限。
	local ct=Duel.GetMatchingGroupCount(c44478599.valfilter,tp,LOCATION_MZONE,0,nil)
	if tc:IsRelateToEffect(e) then
		if ct>1 then
			-- 这个回合，那只怪兽可以作出最多有自己场上的「圣天树」连接怪兽数量的攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(ct-1)
			tc:RegisterEffect(e1)
		elseif ct==0 then
			-- 这个回合，那只怪兽可以作出最多有自己场上的「圣天树」连接怪兽数量的攻击（0只时即不能攻击）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
