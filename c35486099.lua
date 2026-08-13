--宝玉の恵み
-- 效果：
-- ①：以自己墓地最多2只「宝玉兽」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c35486099.initial_effect(c)
	-- ①：以自己墓地最多2只「宝玉兽」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35486099.target)
	e1:SetOperation(c35486099.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的「宝玉兽」怪兽：必须属于「宝玉兽」系列、是怪兽且未被禁止使用。
function c35486099.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 发动时进行对象选定：确认墓地存在符合条件的对象，并根据此卡所在位置检查魔陷区空位；然后选择1~2只符合条件的怪兽作为对象，并设置操作信息。
function c35486099.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35486099.filter(chkc) end
	if chk==0 then
		-- 检查自己墓地是否存在至少1只符合条件的「宝玉兽」怪兽，若不存在则不能发动。
		if not Duel.IsExistingTarget(c35486099.filter,tp,LOCATION_GRAVE,0,1,nil) then return false end
		if e:GetHandler():IsLocation(LOCATION_HAND) then
			-- 当此卡从手牌发动时，需要自己的魔法与陷阱区域至少存在2个空位才能发动。
			return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 否则（此卡不在手牌时），魔法与陷阱区域有至少1个空位即可发动。
		else return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	end
	-- 获取自己当前魔法与陷阱区域的可用空位数量，作为后续可选择数量的上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>2 then ft=2 end
	-- 向操作者展示选择提示，提示内容为“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己墓地的符合条件的「宝玉兽」怪兽中选择1至ft只（最多2只）作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c35486099.filter,tp,LOCATION_GRAVE,0,1,ft,nil)
	-- 设置本连锁将处理从墓地移动卡片的分类，使相关效果（如王家长眠之谷）能正确应对。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：获取当前魔陷区空位，取出发动时选择的对象；筛选仍与效果相关的对象；若对象数超过空位则让操作者选择实际放置的卡；将选中的怪兽移动到自己魔陷区并变为永续魔法卡。
function c35486099.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时自己魔法与陷阱区域的可用空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 获取发动时选择的对象卡组，作为本次效果处理的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		if sg:GetCount()>ft then
			-- 当需要从多个仍相关的对象中选择实际放置到魔陷区的卡时，显示选择提示“请选择要放置到场上的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local rg=sg:Select(tp,ft,ft,nil)
			sg=rg
		end
		local tc=sg:GetFirst()
		while tc do
			-- 将选中的「宝玉兽」怪兽以表侧表示移动到自己的魔法与陷阱区域，并让该卡的效果立即适用。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 那些怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
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
