--聖天樹の灰樹精
-- 效果：
-- 包含连接怪兽的植物族怪兽2只以上
-- ①：这张卡连接召唤成功的场合才能发动。从自己墓地选1只「圣种之地灵」特殊召唤。
-- ②：这张卡不会被作为攻击对象（自己场上只有被这个效果适用的怪兽存在的状态中对方的攻击变成对自己的直接攻击）。
-- ③：1回合1次，以这张卡所连接区1只自己的「圣蔓」连接怪兽为对象才能发动。这个回合，那只怪兽可以作出最多有自己场上的「圣天树」连接怪兽数量的攻击。
function c44478599.initial_effect(c)
	-- 添加连接召唤手续，要求使用2到3个满足条件的植物族连接怪兽作为素材
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
-- 连接怪兽素材必须包含至少1只连接怪兽
function c44478599.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 连接召唤成功时才能发动
function c44478599.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤墓地中的「圣种之地灵」怪兽
function c44478599.spfilter(c,e,tp)
	return c:IsCode(27520594) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且墓地存在「圣种之地灵」
function c44478599.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地存在「圣种之地灵」
		and Duel.IsExistingMatchingCard(c44478599.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只「圣种之地灵」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作，从墓地选择1只「圣种之地灵」特殊召唤
function c44478599.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地选择1只「圣种之地灵」
	local g=Duel.SelectMatchingCard(tp,c44478599.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否能进入战斗阶段
function c44478599.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 判断是否为「圣蔓」连接怪兽且在连接区中
function c44478599.cfilter(c,g)
	return c:IsSetCard(0x1158) and c:IsType(TYPE_LINK) and g:IsContains(c)
end
-- 过滤「圣天树」连接怪兽
function c44478599.valfilter(c)
	return c:IsSetCard(0x2158) and c:IsType(TYPE_LINK)
end
-- 判断是否满足发动条件：场上存在「圣蔓」连接怪兽且「圣天树」连接怪兽数量大于1
function c44478599.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c44478599.cfilter(chkc,lg) end
	-- 判断是否满足发动条件：场上存在「圣蔓」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c44478599.cfilter,tp,LOCATION_MZONE,0,1,nil,lg)
		-- 判断是否满足发动条件：「圣天树」连接怪兽数量大于1
		and Duel.GetMatchingGroupCount(c44478599.valfilter,tp,LOCATION_MZONE,0,nil)>1 end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标「圣蔓」连接怪兽
	Duel.SelectTarget(tp,c44478599.cfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
-- 执行效果处理，根据「圣天树」连接怪兽数量增加攻击次数或禁止攻击
function c44478599.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 统计场上「圣天树」连接怪兽数量
	local ct=Duel.GetMatchingGroupCount(c44478599.valfilter,tp,LOCATION_MZONE,0,nil)
	if tc:IsRelateToEffect(e) then
		if ct>1 then
			-- 给予目标怪兽额外攻击次数
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(ct-1)
			tc:RegisterEffect(e1)
		elseif ct==0 then
			-- 禁止目标怪兽攻击
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
