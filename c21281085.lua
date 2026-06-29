--魔轟神レヴェルゼブル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段才能发动1次。自己场上的「魔轰神」怪兽任意数量解放，得到那个数量的对方场上的表侧表示怪兽的控制权。这个效果得到控制权的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合，以自己墓地1张其他的「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
local s,id,o=GetID()
-- 注册同调召唤、主要阶段夺取控制权、以及回收自身并加入「魔轰神」卡片的效果
function s.initial_effect(c)
	-- 为卡片注册同调召唤的素材要求规程
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
	-- ②：这张卡在墓地存在的场合，以自己墓地1张其他地「魔轰神」卡为对象才能发动。这张卡回到额外卡组，作为对象的卡加入手卡。
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
-- 主要阶段的发动条件判断
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前正处于自己或对方的主要阶段
	return Duel.IsMainPhase()
end
-- 用作解放代价的自己场上「魔轰神」怪兽的过滤条件
function s.rfilter(c,tp)
	-- 检查在将该魔轰神解放之后，是否能满足夺取对方怪兽控制权的空位要求
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上是否存在能够被夺取控制权的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,c)
end
-- 可以被夺取控制权的对方场上表侧表示怪兽的过滤条件
function s.ctfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
-- 夺取控制权效果的发动准备
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在满足解放条件的「魔轰神」怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_EFFECT,false,nil,tp) end
	-- 设置操作信息为解放自己场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置操作信息为夺取对方怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
-- 夺取控制权效果的执行
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上表侧表示的所有可夺取控制权的怪兽
	local og=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	if og:GetCount()==0 then return end
	-- 获取自己场上所有可作为解放代价的「魔轰神」怪兽
	local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(s.rfilter,nil,tp)
	-- 向玩家发送提示，请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:Select(tp,1,og:GetCount(),nil)
	-- 解放选中的自己场上的「魔轰神」怪兽并记录解放数量
	local ct=Duel.Release(sg,REASON_EFFECT)
	if ct>0 then
		-- 向玩家发送提示，请选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 选择对方场上与解放数量相同的怪兽为夺取控制权对象
		local tg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,ct,ct,nil)
		-- 确认并点亮所选择的夺取控制权怪兽
		Duel.HintSelection(tg)
		-- 获得选中怪兽的控制权
		if Duel.GetControl(tg,tp)==0 then return end
		local cg=tg:Filter(Card.IsControler,nil,tp)
		-- 遍历已成功夺取控制权的怪兽以适用效果无效化
		for tc in aux.Next(cg) do
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 注册使所夺取怪兽的效果无效化的单体持续效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 可回收的墓地「魔轰神」卡片的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x35) and c:IsAbleToHand()
end
-- 回收自身并加入手卡效果的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 检查自己墓地中是否存在除自身外满足回收条件的「魔轰神」卡片
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1张满足条件的「魔轰神」卡片为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息为将选中的卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息为将墓地的此卡返回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 回收自身并加入手卡效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的墓地「魔轰神」回收目标
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 若此卡成功返回额外卡组，则继续处理
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 检查回收目标是否依然符合回收条件
		and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将选中的「魔轰神」卡片从墓地加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
