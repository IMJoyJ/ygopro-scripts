--フォーチュンフューチャー
-- 效果：
-- ①：以除外的1只自己的「命运女郎」怪兽为对象才能发动。那只怪兽回到墓地。那之后，自己从卡组抽2张。
function c68663748.initial_effect(c)
	-- ①：以除外的1只自己的「命运女郎」怪兽为对象才能发动。那只怪兽回到墓地。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c68663748.target)
	e1:SetOperation(c68663748.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：除外区表侧表示的「命运女郎」怪兽
function c68663748.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER)
end
-- 效果发动的对象合法性检查与发动条件判断
function c68663748.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c68663748.filter(chkc) end
	-- 检查玩家是否具有抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查除外区是否存在符合条件的「命运女郎」怪兽
		and Duel.IsExistingTarget(c68663748.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(68663748,0))  --"请选择要返回墓地的卡"
	-- 选择除外区的1只自己的「命运女郎」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c68663748.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将对象卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理的执行函数
function c68663748.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		-- 中断效果处理，使后续的抽卡处理与送去墓地不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
