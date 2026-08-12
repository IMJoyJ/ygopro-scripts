--No.5 亡朧竜 デス・キマイラ・ドラゴン
-- 效果：
-- 5星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
-- ②：持有超量素材的这张卡可以向对方怪兽全部各作1次攻击。
-- ③：这张卡进行战斗的战斗阶段结束时，可以从以下效果选择1个发动。
-- ●以自己墓地1只怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ●以对方墓地1张卡为对象才能发动。那张卡回到对方卡组最上面。
function c90126061.initial_effect(c)
	-- 添加超量召唤手续：等级5怪兽2只以上
	aux.AddXyzProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c90126061.atkval)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡可以向对方怪兽全部各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(c90126061.allcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时，可以从以下效果选择1个发动。●以自己墓地1只怪兽为对象才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(90126061,0))  --"自己墓地的卡作为超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c90126061.con)
	e3:SetTarget(c90126061.mttg)
	e3:SetOperation(c90126061.mtop)
	c:RegisterEffect(e3)
	-- ③：这张卡进行战斗的战斗阶段结束时，可以从以下效果选择1个发动。●以对方墓地1张卡为对象才能发动。那张卡回到对方卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90126061,1))  --"对方墓地的卡回到卡组最上"
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c90126061.con)
	e4:SetTarget(c90126061.rettg)
	e4:SetOperation(c90126061.retop)
	c:RegisterEffect(e4)
end
-- 设置该卡为“No.5”怪兽
aux.xyz_number[90126061]=5
-- 攻击力上升值等于超量素材数量乘以1000
function c90126061.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 攻击全部怪兽效果的启用条件：自身是超量怪兽且持有超量素材
function c90126061.allcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsType(TYPE_XYZ) and e:GetHandler():GetOverlayCount()>0
end
-- 效果发动条件：这张卡在本次战斗阶段进行过战斗
function c90126061.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 过滤条件：墓地中可以作为超量素材的怪兽卡
function c90126061.mtfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果1（重叠素材）的发动准备与目标选择
function c90126061.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90126061.mtfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查自己墓地是否存在可以作为超量素材的怪兽
		and Duel.IsExistingTarget(c90126061.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择自己墓地1只怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c90126061.mtfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
-- 效果1（重叠素材）的效果处理：将目标怪兽重叠作为超量素材
function c90126061.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的墓地怪兽目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 效果2（回卡组顶）的发动准备与目标选择
function c90126061.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查对方墓地是否存在可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,1-tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1张卡作为效果对象
	local sg=Duel.SelectTarget(tp,Card.IsAbleToDeck,1-tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：目标卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
end
-- 效果2（回卡组顶）的效果处理：将目标卡片送回对方卡组最上面
function c90126061.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对方墓地卡片目标
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
