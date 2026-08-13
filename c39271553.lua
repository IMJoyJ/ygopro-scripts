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
-- 定义①效果可取对象的怪兽条件：表侧表示、属于「方程式运动员」系列、当前等级高于原本等级。
function c39271553.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107) and c:GetLevel()>c:GetOriginalLevel()
end
-- ①效果的发动条件与取对象处理：检查自身可特殊召唤、己方主要怪兽区有空位、场上存在满足条件的「方程式运动员」怪兽；发动时选择1只满足条件的怪兽作为对象。
function c39271553.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c39271553.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查己方主要怪兽区是否有可用的空格，用于确保特殊召唤有可用格子。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在1只以上满足条件的「方程式运动员」怪兽（表侧表示且等级高于原本等级），作为发动①效果的必要条件。
		and Duel.IsExistingTarget(c39271553.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择提示，提示内容为“请选择表侧表示的卡”，用于后续选择对象时的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的「方程式运动员」怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c39271553.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本效果含有特殊召唤，特殊召唤的对象是这张卡本身，数量为1，用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：将这张卡特殊召唤；若特殊召唤成功，获取对象怪兽并计算其当前等级与原本等级的差值，然后使对象怪兽等级下降该差值，并使这张卡等级变为该差值。
function c39271553.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 进行分步特殊召唤，将这张卡以表侧表示特殊召唤到己方场上；此步骤返回是否特殊召唤成功。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取发动时选择的对象怪兽（取对象目标）。
		local tc=Duel.GetFirstTarget()
		local lv=math.abs(tc:GetLevel()-tc:GetOriginalLevel())
		if tc:IsRelateToEffect(e) and lv>0 then
			-- 作为对象的怪兽的等级下降和那个原本等级的相差数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的这张卡的等级变成和那个相差数值相同。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
		end
	end
	-- 完成分步特殊召唤处理，结束整个特殊召唤过程，并触发特殊召唤成功时应发动的时点。
	Duel.SpecialSummonComplete()
end
-- 定义②效果检索的卡的条件：属于「方程式运动员」系列、场地魔法卡、并且能够加入手卡。
function c39271553.thfilter(c)
	return c:IsSetCard(0x107) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- ②效果的发动条件检查与操作信息设置：确认卡组中存在满足条件的「方程式运动员」场地魔法卡；设置操作信息，表示效果处理时从卡组将1张卡加入手牌。
function c39271553.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「方程式运动员」场地魔法卡，作为②效果的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c39271553.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手牌，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张「方程式运动员」场地魔法卡加入手牌，并让对方确认加入手牌的卡。
function c39271553.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「方程式运动员」场地魔法卡。
	local g=Duel.SelectMatchingCard(tp,c39271553.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌（nil表示加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚刚加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
