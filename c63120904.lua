--暗黒大要塞鯱
-- 效果：
-- 祭掉自己场上1只「鱼雷鱼」，破坏对方场上1只怪兽。祭掉自己场上1只「炮弹枪贝」，破坏对方场上1张魔法·陷阱卡。
function c63120904.initial_effect(c)
	-- 祭掉自己场上1只「鱼雷鱼」，破坏对方场上1只怪兽。祭掉自己场上1只「炮弹枪贝」，破坏对方场上1张魔法·陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63120904,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c63120904.target)
	e1:SetOperation(c63120904.operation)
	c:RegisterEffect(e1)
end
-- 过滤解放怪兽的条件：卡名为「鱼雷鱼」或「炮弹枪贝」
function c63120904.rfilter(c)
	return c:IsCode(90337190,95614612)
end
-- 过滤破坏目标的条件：魔法或陷阱卡
function c63120904.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的对象选择与合法性检查
function c63120904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==90337190 then return chkc:IsLocation(LOCATION_MZONE)
		else return chkc:IsOnField() and c63120904.dfilter(chkc) end
	end
	-- 检查是否能解放自己场上1只「鱼雷鱼」且场上存在可作为对象的怪兽
	local b1=Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,90337190) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查是否能解放自己场上1只「炮弹枪贝」且场上存在可作为对象的魔法·陷阱卡
	local b2=Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,95614612) and Duel.IsExistingTarget(c63120904.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local code=0
	if b1 and b2 then
		-- 在两种代价都满足时，让玩家选择解放自己场上1只「鱼雷鱼」或「炮弹枪贝」
		local rg=Duel.SelectReleaseGroup(tp,c63120904.rfilter,1,1,nil)
		code=rg:GetFirst():GetCode()
		-- 解放选中的怪兽作为发动代价
		Duel.Release(rg,REASON_COST)
	elseif b1 then
		-- 在仅满足「鱼雷鱼」代价时，让玩家选择解放自己场上1只「鱼雷鱼」
		local rg=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,90337190)
		code=90337190
		-- 解放「鱼雷鱼」作为发动代价
		Duel.Release(rg,REASON_COST)
	else
		-- 在仅满足「炮弹枪贝」代价时，让玩家选择解放自己场上1只「炮弹枪贝」
		local rg=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,95614612)
		code=95614612
		-- 解放「炮弹枪贝」作为发动代价
		Duel.Release(rg,REASON_COST)
	end
	e:SetLabel(code)
	if code==90337190 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1只怪兽作为效果对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 设置效果处理信息为破坏选中的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张魔法·陷阱卡作为效果对象
		local g=Duel.SelectTarget(tp,c63120904.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 设置效果处理信息为破坏选中的魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理的执行函数
function c63120904.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏选中的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
