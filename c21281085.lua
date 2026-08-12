--魔轟神レヴェルゼブル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动1次。自己场上的「魔轰神」怪兽任意数量解放，得到那个数量的对方场上的表侧表示怪兽的控制权。这个效果得到控制权的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合，以自己墓地1张其他的「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续与苏生限制，注册①效果（诱发即时、场上、1回合1次）和②效果（起动效果、墓地、取对象、1回合1次）
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：素材为调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段才能发动1次。自己场上的「魔轰神」怪兽任意数量解放，得到那个数量的对方场上的表侧表示怪兽的控制权。这个效果得到控制权的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"得到控制权"
	e1:SetCategory(CATEGORY_RELEASE|CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己墓地1张其他的「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOEXTRA|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：判断是否处于自己或对方的主要阶段
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前处于自己或对方的主要阶段时才能发动
	return Duel.IsMainPhase()
end
-- 可作为解放对象的卡的过滤函数：须为「魔轰神」怪兽，且将其解放后有可用的主要怪兽区，并能得到对方怪兽的控制权
function s.rfilter(c,tp)
	-- 这张卡是「魔轰神」怪兽，且解放它之后自己场上还有可用的主要怪兽区来放置改变控制权的怪兽
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 除这张卡以外，对方场上存在可以改变控制权的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,c)
end
-- 可被夺取控制权的卡的过滤函数：须为表侧表示且控制权可以变更的怪兽
function s.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- ①效果的发动目标处理：检查是否存在满足条件的可解放怪兽，并预设解放和改变控制权的操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动条件检查：自己场上存在至少1张满足过滤条件的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_EFFECT,false,nil,tp) end
	-- 预设操作信息：将解放1张卡（解放的卡在处理时才能确定）
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 预设操作信息：将得到1只对方怪兽的控制权（对象在处理时才能确定）
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- ①效果的处理：解放自己场上任意数量的「魔轰神」怪兽，得到同数量的对方表侧表示怪兽的控制权，并使得到控制权的怪兽的效果无效化
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上所有可以改变控制权的表侧表示怪兽
	local og=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	if og:GetCount()==0 then return end
	-- 取得自己场上可解放的卡中满足「魔轰神」怪兽条件的卡组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(s.rfilter,nil,tp)
	-- 向自己发送选择提示：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:Select(tp,1,og:GetCount(),nil)
	-- 解放选择的「魔轰神」怪兽，返回实际解放的数量
	local ct=Duel.Release(sg,REASON_EFFECT)
	if ct>0 then
		-- 向自己发送选择提示：请选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让自己从对方场上选择与解放数量相同的可以改变控制权的表侧表示怪兽
		local tg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
		-- 为选择的对方怪兽显示被选中的动画并记录
		Duel.HintSelection(tg)
		-- 得到那些对方怪兽的控制权，失败则中止处理
		if Duel.GetControl(tg,tp)==0 then return end
		local cg=tg:Filter(Card.IsControler,nil,tp)
		-- 逐个遍历控制权已变为自己的那些怪兽
		for tc in aux.Next(cg) do
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 可作为回收对象的卡的过滤函数：须为可以加入手卡的「魔轰神」卡
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsAbleToHand()
end
-- ②效果的发动目标处理：检查对象位置合法性、这张卡能否回到额外卡组、以及墓地是否存在可作为对象的其他「魔轰神」卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 以自己墓地1张其他的满足条件的「魔轰神」卡为对象才能发动
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向自己发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 以自己墓地1张其他的「魔轰神」卡为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 预设操作信息：作为对象的1张卡将加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 预设操作信息：这张卡将回到额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- ②效果的处理：这张卡回到额外卡组，作为对象的卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得作为效果对象的那张卡
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 这张卡与效果仍相关联且不受王家长眠之谷影响时，把这张卡洗回持有者的额外卡组
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 这张卡已在额外卡组，且作为对象的卡仍与效果相关联且不受王家长眠之谷影响
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 把作为对象的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
