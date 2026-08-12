--スプリガンズ・ロッキー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「护宝炮妖·小火箭」以外的自己墓地1只「护宝炮妖」怪兽或者1张「大沙海 黄金戈尔工达」为对象才能发动。那张卡加入手卡。
-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c20424878.initial_effect(c)
	-- 注册卡片代码列表，记录该卡与「大沙海 黄金戈尔工达」（60884672）的关联
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
-- 检索满足条件的墓地怪兽或「大沙海 黄金戈尔工达」，且不是自身，且可以加入手牌
function c20424878.thfilter(c)
	return (c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) or c:IsCode(60884672)) and not c:IsCode(20424878) and c:IsAbleToHand()
end
-- 设置效果处理时的条件判断，检查是否存在满足条件的目标
function c20424878.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20424878.thfilter(chkc) end
	-- 检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c20424878.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地目标卡
	local g=Duel.SelectTarget(tp,c20424878.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的执行操作，将目标卡加入手牌
function c20424878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 筛选满足条件的场上超量怪兽，必须是「护宝炮妖」且为超量怪兽
function c20424878.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 设置效果处理时的条件判断，检查是否存在满足条件的目标
function c20424878.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c20424878.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c20424878.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的场上目标怪兽
	Duel.SelectTarget(tp,c20424878.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置效果处理信息，记录该卡将离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 处理效果的执行操作，将该卡作为超量素材叠放
function c20424878.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsCanOverlay() and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将该卡原本叠放的卡送入墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将该卡叠放到目标怪兽上
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
