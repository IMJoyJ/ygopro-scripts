--宝玉の恵み
-- 效果：
-- ①：以自己墓地最多2只「宝玉兽」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c35486099.initial_effect(c)
	-- 效果原文：①：以自己墓地最多2只「宝玉兽」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35486099.target)
	e1:SetOperation(c35486099.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的墓地宝玉兽怪兽
function c35486099.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果作用：选择1~2只自己墓地的宝玉兽怪兽作为对象
function c35486099.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35486099.filter(chkc) end
	if chk==0 then
		-- 判断是否满足选择对象的条件
		if not Duel.IsExistingTarget(c35486099.filter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			-- 若发动卡在手牌中，判断场上是否有2个以上魔法陷阱区域空位
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 若发动卡不在手牌中，判断场上是否有1个以上魔法陷阱区域空位
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	-- 获取当前玩家魔法陷阱区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>2 then ft=2 end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的墓地宝玉兽怪兽作为对象
	local g=Duel.SelectTarget(tp,c35486099.filter,tp,LOCATION_GRAVE,0,1,ft,nil)
	-- 设置效果处理信息，记录将要处理的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 效果作用：将选中的宝玉兽怪兽当作永续魔法卡使用并放置到魔法陷阱区域
function c35486099.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家魔法陷阱区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 获取连锁中已选定的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		if sg:GetCount()>ft then
			-- 提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local rg=sg:Select(tp,ft,ft,nil)
			sg=rg
		end
		local tc=sg:GetFirst()
		while tc do
			-- 将对象怪兽移动到魔法陷阱区域并表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 效果原文：①：以自己墓地最多2只「宝玉兽」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end
	end
end
