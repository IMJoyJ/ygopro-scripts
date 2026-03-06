--マジキャット
-- 效果：
-- 这张卡被魔法师族怪兽的同调召唤使用送去墓地的场合，可以让自己墓地存在的1张魔法卡回到卡组最上面。
function c25531465.initial_effect(c)
	-- 创建一个诱发选发效果，当此卡因同调召唤被送入墓地时可以发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25531465,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c25531465.tdcon)
	e1:SetTarget(c25531465.tdtg)
	e1:SetOperation(c25531465.tdop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：此卡在墓地且因同调召唤被送入墓地，且将其送入墓地的怪兽为魔法师族
function c25531465.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsRace(RACE_SPELLCASTER)
end
-- 筛选条件：目标为魔法卡且可以送回卡组
function c25531465.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 效果处理目标选择：选择1张自己墓地的魔法卡作为对象
function c25531465.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25531465.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c25531465.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择：向玩家提示选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标：选择1张自己墓地的魔法卡作为对象
	local g=Duel.SelectTarget(tp,c25531465.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的卡设置为本次效果处理的对象
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理执行：将选中的魔法卡送回卡组最上面
function c25531465.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡：获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组：将目标卡以效果原因送回卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
