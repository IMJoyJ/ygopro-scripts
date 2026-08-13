--スプリガンズ・ロッキー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「护宝炮妖·小火箭」以外的自己墓地1只「护宝炮妖」怪兽或者1张「大沙海 黄金戈尔工达」为对象才能发动。那张卡加入手卡。
-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c20424878.initial_effect(c)
	-- 将卡号60884672（大沙海 黄金戈尔工达）登记为此卡名字段中记载的卡。
	aux.AddCodeList(c,60884672)
	-- ①：这张卡召唤·特殊召唤的场合，以「护宝炮妖·小火箭」以外的自己墓地1只「护宝炮妖」怪兽或者1张「大沙海 黄金戈尔工达」为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20424878,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20424878)
	e1:SetTarget(c20424878.thtg)
	e1:SetOperation(c20424878.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20424878,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,20424879)
	e3:SetTarget(c20424878.ovtg)
	e3:SetOperation(c20424878.ovop)
	c:RegisterEffect(e3)
end
-- 定义①效果可选择的对象条件：自己墓地的「护宝炮妖」怪兽或「大沙海 黄金戈尔工达」，且不能是「护宝炮妖·小火箭」自身，并且该卡能够加入手卡。
function c20424878.thfilter(c)
	return (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(60884672)) and not c:IsCode(20424878) and c:IsAbleToHand()
end
-- ①效果的目标选择处理：效果发动时检查合法对象，并让玩家从自己墓地选择1张符合条件的卡作为效果对象。
function c20424878.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20424878.thfilter(chkc) end
	-- 效果发动检查：确认自己墓地存在至少1张满足thfilter条件的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20424878.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示，用于选择对象时的人机交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足thfilter条件的卡作为效果对象，并自动登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c20424878.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本连锁的操作信息为“将卡加入手卡”，供连锁判定等相关效果使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理函数：取得对象卡，若对象仍与本效果关联，则将其加入手卡。
function c20424878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中登记的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义②效果可选择对象条件：自己场上的表侧表示「护宝炮妖」超量怪兽。
function c20424878.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- ②效果的目标合法性判断：候选对象必须是己方场上的表侧表示「护宝炮妖」超量怪兽且不是自身；发动回检查场上是否存在合法对象以及自身是否可作为超量素材。
function c20424878.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20424878.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 效果发动检查：确认自己场上存在至少1只满足ovfilter的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c20424878.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 向玩家显示“请选择效果的对象”的提示，用于选择超量怪兽时的人机交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只表侧表示「护宝炮妖」超量怪兽作为效果对象（排除自身）。
	Duel.SelectTarget(tp,c20424878.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 登记操作信息：若此卡在墓地发动，则标记其将离开墓地，使相关效果能正确判别。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ②效果处理函数：将此卡叠放在对象超量怪兽下方；若此卡本身持有超量素材，先将那些素材以规则原因送入墓地。
function c20424878.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得选择的对象超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将原本作为此卡超量素材的卡片以规则原因送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将这张卡作为对象超量怪兽的超量素材叠放。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
