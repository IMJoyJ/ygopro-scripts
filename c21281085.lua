--魔轟神レヴェルゼブル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动1次。自己场上的「魔轰神」怪兽任意数量解放，得到那个数量的对方场上的表侧表示怪兽的控制权。这个效果得到控制权的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合，以自己墓地1张其他的「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：自己·对方的主要阶段才能发动1次。自己场上的「魔轰神」怪兽任意数量解放，得到那个数量的对方场上的表侧表示怪兽的控制权。这个效果得到控制权的怪兽的效果无效化。
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
	-- 效果②：这张卡在墓地存在的场合，以自己墓地1张其他的「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
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
-- 效果①的发动条件：只能在主要阶段发动
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 只能在主要阶段发动
	return Duel.IsMainPhase()
end
-- 解放怪兽的过滤条件：满足魔轰神卡组、是怪兽、有可用的怪兽区、对方场上存在可控制的怪兽
function s.rfilter(c,tp)
	-- 满足魔轰神卡组、是怪兽、有可用的怪兽区
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 对方场上存在可控制的怪兽
		and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,c)
end
-- 可控制的怪兽的过滤条件：表侧表示且能改变控制权
function s.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- 效果①的发动时点处理，检查是否满足解放条件并设置操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_EFFECT,false,nil,tp) end
	-- 设置将要解放的卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置将要改变控制权的卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 效果①的处理过程：选择解放的怪兽并进行解放，然后选择对方怪兽改变控制权并使其效果无效
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上可控制的怪兽组
	local og=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	if og:GetCount()==0 then return end
	-- 获取可解放的魔轰神怪兽组
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(s.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:Select(tp,1,og:GetCount(),nil)
	-- 执行解放操作
	local ct=Duel.Release(sg,REASON_EFFECT)
	if ct>0 then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上满足条件的怪兽
		local tg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
		-- 显示被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 执行改变控制权操作
		if not Duel.GetControl(tg,tp) then return end
		local cg=tg:Filter(Card.IsControler,nil,tp)
		-- 遍历所有获得控制权的怪兽
		for tc in aux.Next(cg) do
			-- 使该怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使该怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 墓地魔轰神卡的过滤条件：是魔轰神卡组且能加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsAbleToHand()
end
-- 效果②的发动时点处理，检查是否满足发动条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查对方墓地是否存在满足条件的魔轰神卡
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标魔轰神卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置将要加入手牌的卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置将要回到额外卡组的卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 效果②的处理过程：将自身送回额外卡组，将目标卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标卡片
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 检查自身是否满足送回额外卡组的条件
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 检查目标卡是否满足加入手牌的条件
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
