--聖魔の大賢者エンディミオン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组选1只「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
-- ②：以自己场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，自己从卡组抽1张。那之后，选1张手卡回到卡组最下面。
function c9482987.initial_effect(c)
	-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组选1只「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9482987,0))  --"从额外卡组选1只「法典贤者」怪兽装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9482987)
	e1:SetTarget(c9482987.eqtg)
	e1:SetOperation(c9482987.eqop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，自己从卡组抽1张。那之后，选1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9482987,1))  --"从卡组抽1张，选1张手卡回到卡组最下面"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9482988)
	e2:SetTarget(c9482987.drtg)
	e2:SetOperation(c9482987.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「大贤者」怪兽
function c9482987.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 过滤条件：额外卡组的「大贤者」怪兽
function c9482987.eqfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER)
end
-- 效果①的发动条件判定与对象选择
function c9482987.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9482987.tgfilter(chkc) end
	-- 判定自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以作为对象的「大贤者」怪兽
		and Duel.IsExistingTarget(c9482987.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判定额外卡组是否存在可以装备的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c9482987.eqfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「大贤者」怪兽作为效果对象
	Duel.SelectTarget(tp,c9482987.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：从额外卡组将1只「大贤者」怪兽给对象怪兽装备
function c9482987.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍在场上表侧表示存在，且魔陷区是否有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从额外卡组选择1只「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,c9482987.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local ec=g:GetFirst()
		if ec then
			-- 将选中的怪兽作为装备卡装备给对象怪兽，若失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(c9482987.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制：只能装备给作为对象的怪兽
function c9482987.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤条件：自己场上表侧表示的魔法卡
function c9482987.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果②的发动条件判定与对象选择
function c9482987.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c9482987.desfilter(chkc) end
	-- 判定自己场上是否存在可以作为对象的表侧表示魔法卡
	if chk==0 then return Duel.IsExistingTarget(c9482987.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判定玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c9482987.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置破坏操作的信息，涉及对象为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置抽卡操作的信息，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置将手卡送回卡组操作的信息，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果②的处理：破坏对象卡并抽卡，之后将1张手卡送回卡组最下面
function c9482987.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的魔法卡
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡是否仍关联效果，将其破坏并抽1张卡，且两步均成功执行
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.Draw(tp,1,REASON_EFFECT)~=0
		-- 判定手卡中是否存在可以送回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) then
		-- 中断当前效果处理，使后续处理不与前面的破坏、抽卡同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择1张卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的手卡送回卡组最下面
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
