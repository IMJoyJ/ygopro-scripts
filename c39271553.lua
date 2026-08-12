--F.A.カーナビゲーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只持有比原本等级高的等级的「方程式运动员」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的等级下降和那个原本等级的相差数值。这个效果特殊召唤的这张卡的等级变成和那个相差数值相同。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方程式运动员」场地魔法卡加入手卡。
function c39271553.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以自己场上1只持有比原本等级高的等级的「方程式运动员」怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽的等级下降和那个原本等级的相差数值。这个效果特殊召唤的这张卡的等级变成和那个相差数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39271553,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,39271553)
	e1:SetTarget(c39271553.sptg)
	e1:SetOperation(c39271553.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「方程式运动员」场地魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39271553,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,39271554)
	e2:SetTarget(c39271553.thtg)
	e2:SetOperation(c39271553.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的「方程式运动员」怪兽（表侧表示且等级高于原本等级）
function c39271553.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:GetLevel()>c:GetOriginalLevel()
end
-- 设置效果的发动条件：检查手牌或墓地中的这张卡是否可以特殊召唤，且场上是否存在满足条件的目标怪兽
function c39271553.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c39271553.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家场上是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c39271553.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c39271553.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理效果的发动，执行特殊召唤操作并修改目标怪兽和自身等级
function c39271553.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试特殊召唤这张卡
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取当前效果的目标怪兽
		local tc=Duel.GetFirstTarget()
		local lv=math.abs(tc:GetLevel()-tc:GetOriginalLevel())
		if tc:IsRelateToEffect(e) and lv>0 then
			-- 使目标怪兽的等级下降相差数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使这张卡的等级变为相差数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 过滤函数，用于判断卡组中是否存在满足条件的「方程式运动员」场地魔法卡
function c39271553.thfilter(c)
	return c:IsSetCard(0x107) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 设置效果的发动条件：检查卡组中是否存在满足条件的场地魔法卡
function c39271553.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39271553.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将场地魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，选择并加入手牌
function c39271553.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c39271553.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的场地魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
