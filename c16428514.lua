--サブテラーの導師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把「地中族导师」以外的1张「地中族」卡加入手卡。
-- ②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡变成里侧守备表示。自己场上有这张卡以外的「地中族」卡存在的场合，这个效果在对方回合也能发动。
function c16428514.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡反转的场合才能发动。从卡组把「地中族导师」以外的1张「地中族」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16428514,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16428514)
	e1:SetTarget(c16428514.thtg)
	e1:SetOperation(c16428514.thop)
	c:RegisterEffect(e1)
	-- ②：以场上1只其他的表侧表示怪兽为对象才能发动（自己场上有其他的「地中族」卡存在的场合，这个效果在对方回合也能发动）。那只怪兽和这张卡变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16428514,1))  --"变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16428515)
	e2:SetCondition(c16428514.setcon1)
	e2:SetTarget(c16428514.settg)
	e2:SetOperation(c16428514.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c16428514.setcon2)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：卡必须是「地中族」字段、不是「地中族导师」自身、且能够加入手卡。
function c16428514.thfilter(c)
	return c:IsSetCard(0xed) and not c:IsCode(16428514) and c:IsAbleToHand()
end
-- ①效果的目标设定与发动条件确认：检查卡组中是否存在符合条件的检索对象，并设置从卡组将1张卡加入手卡的操作信息。
function c16428514.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中必须存在至少1张满足thfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16428514.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（不取对象，数量1，所属玩家为tp），用于连锁发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1张符合条件的「地中族」卡加入手卡，并向对方展示。
function c16428514.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中筛选并选出1张满足thfilter条件的卡（检索选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c16428514.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示按持有者），原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义字段过滤：检查怪兽是否表侧表示且属于「地中族」字段。
function c16428514.setcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xed)
end
-- e2（通常起动版②效果）的发动条件：自己场上没有其他表侧表示的「地中族」卡时才能发动。
function c16428514.setcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上不存在其他表侧表示的地中族卡（排除自身），满足setcon1条件。
	return not Duel.IsExistingMatchingCard(c16428514.setcfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- e3（快速效果版②效果）的发动条件：自己场上有其他表侧表示的「地中族」卡时才能发动（支持对方回合发动）。
function c16428514.setcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上存在其他表侧表示的地中族卡（排除自身），满足setcon2条件。
	return Duel.IsExistingMatchingCard(c16428514.setcfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 定义目标过滤：怪兽必须表侧表示且可以变成里侧守备表示。
function c16428514.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的取对象目标设定：若连锁中验证对象则检查对象合法性；发动时确认自身可转里侧且场上存在其他合法对象。
function c16428514.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c16428514.setfilter(chkc) end
	if chk==0 then return c16428514.setfilter(c)
		-- 在发动合法性检查中，确认场上存在至少1只除自身以外、满足setfilter条件的怪兽（取对象）。
		and Duel.IsExistingTarget(c16428514.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 显示选择提示，让玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从场上选择1只除自身以外、表侧表示且可变为里侧守备的怪兽，并登记为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c16428514.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	g:AddCard(c)
	-- 设置操作信息：本次效果将改变2张卡（对象怪兽和自身）的表示形式，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end
-- ②效果处理：确认自身和对象怪兽仍表侧且与本效果关联后，将二者都变为里侧守备表示。
function c16428514.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象怪兽，用于后续处理。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将g中的卡（自身和目标怪兽）变更为里侧守备表示。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
