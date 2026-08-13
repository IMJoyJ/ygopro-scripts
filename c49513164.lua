--召喚獣ライディーン
-- 效果：
-- 「召唤师 阿莱斯特」＋风属性怪兽
-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
function c49513164.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：以「召唤师 阿莱斯特」＋风属性怪兽为融合素材。
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WIND),1,true,true)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49513164,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c49513164.settg)
	e1:SetOperation(c49513164.setop)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的怪兽：必须是表侧表示且可以被变成里侧守备表示的怪兽。
function c49513164.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果的目标选择函数：检查能否选择场上满足条件的怪兽为对象；确认可发动后提示选择对象、选定目标并登记改变表示形式的操作信息。
function c49513164.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49513164.setfilter(chkc) end
	-- 发动条件判定：检查场上是否存在至少1只表侧表示且可变成里侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49513164.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要改变表示形式的怪兽”的提示信息，并确定选择卡牌的提示文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作玩家从双方怪兽区域选择1只满足条件的表侧表示怪兽作为效果对象，并将其锁定为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c49513164.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：本次效果涉及改变表示形式，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数：取得对象怪兽，若其仍为表侧表示且与发动时状态相关，则将其变成里侧守备表示。
function c49513164.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
