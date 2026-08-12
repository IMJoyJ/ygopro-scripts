--セイクリッド・テンペスト
-- 效果：
-- 「星圣暴风」的①的效果在决斗中只能使用1次。
-- ①：自己结束阶段以自己场上2只持有超量素材的「星圣」超量怪兽为对象才能发动。那2只超量怪兽的超量素材全部取除，对方基本分变成一半。
-- ②：自己准备阶段以自己场上1只「星圣」超量怪兽和自己墓地1只「星圣」怪兽为对象才能发动。那只墓地的怪兽在那只超量怪兽下面重叠作为超量素材。
function c4820694.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己结束阶段以自己场上2只持有超量素材的「星圣」超量怪兽为对象才能发动。那2只超量怪兽的超量素材全部取除，对方基本分变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4820694,0))  --"基本分变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4820694+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c4820694.condition)
	e2:SetTarget(c4820694.lptg)
	e2:SetOperation(c4820694.lpop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段以自己场上1只「星圣」超量怪兽和自己墓地1只「星圣」怪兽为对象才能发动。那只墓地的怪兽在那只超量怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4820694,1))  --"超量素材增加"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c4820694.condition)
	e3:SetTarget(c4820694.mattg)
	e3:SetOperation(c4820694.matop)
	c:RegisterEffect(e3)
end
-- 判断是否为当前回合玩家
function c4820694.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 筛选满足条件的「星圣」超量怪兽（表侧表示、种族为星圣、类型为超量、有超量素材）
function c4820694.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 设置效果目标：选择2只满足条件的场上怪兽
function c4820694.lptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4820694.filter(chkc) end
	-- 检查是否满足选择2只符合条件怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c4820694.filter,tp,LOCATION_MZONE,0,2,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择2只满足条件的场上怪兽作为效果对象
	Duel.SelectTarget(tp,c4820694.filter,tp,LOCATION_MZONE,0,2,2,nil)
end
-- 处理效果：将目标怪兽的超量素材全部送去墓地，然后将对方基本分减半
function c4820694.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) then
		local og1=tc1:GetOverlayGroup()
		local og2=tc2:GetOverlayGroup()
		og1:Merge(og2)
		-- 将目标怪兽的超量素材送去墓地，若未能全部送去则不继续处理
		if Duel.SendtoGrave(og1,REASON_EFFECT)<og1:GetCount() then return end
		-- 将对方基本分减半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
-- 筛选满足条件的「星圣」超量怪兽（表侧表示、种族为星圣、类型为超量）
function c4820694.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:IsType(TYPE_XYZ)
end
-- 筛选满足条件的「星圣」怪兽（种族为星圣、类型为怪兽、可以作为超量素材）
function c4820694.mfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 设置效果目标：选择1只满足条件的场上怪兽和1只满足条件的墓地怪兽
function c4820694.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足选择1只符合条件场上怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c4820694.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否满足选择1只符合条件墓地怪兽的条件
		and Duel.IsExistingTarget(c4820694.mfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的场上怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c4820694.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择1只满足条件的墓地怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c4820694.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：指定将1张墓地怪兽卡移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
end
-- 筛选满足条件的墓地怪兽（与效果相关、可以作为超量素材）
function c4820694.matfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsCanOverlay()
end
-- 处理效果：将目标墓地怪兽叠放至目标超量怪兽下方
function c4820694.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 从连锁对象中筛选出符合条件的墓地怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c4820694.matfilter,tc,e)
	if g:GetCount()>0 then
		-- 将符合条件的墓地怪兽叠放至目标超量怪兽下方
		Duel.Overlay(tc,g)
	end
end
