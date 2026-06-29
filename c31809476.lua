--紋章の明滅
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以对方场上的表侧表示怪兽任意数量为对象才能发动。那些怪兽的卡名当作「不明」使用。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册将对方怪兽卡名改为「不明」的效果、以及结束阶段从墓地盖放自身的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「不明」（卡片密码：77571455）
	aux.AddCodeList(c,77571455)
	-- ①：以对方场上的表侧表示怪兽任意数量为对象才能发动。那些怪兽的卡名当作「不明」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡名变更"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 对方场上尚未被更名为「不明」的表侧表示怪兽的过滤条件
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(77571455)
end
-- 卡名变更效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:IsCode(77571455) end
	-- 检查对方场上是否存在可以作为卡名变更对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示，请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上任意数量的怪兽作为卡名变更对象
	local g=Duel.SelectTarget(tp,s.codefilter,tp,0,LOCATION_MZONE,1,99,nil)
end
-- 确认作为对象的怪兽依然在场上表侧表示存在
function s.acfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
end
-- 卡名变更效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁且当前表侧表示存在的被选择怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.acfilter,nil,e)
	-- 遍历每一个符合条件的目标怪兽以适用卡名变更
	for tc in aux.Next(g) do
		-- 注册使选中怪兽的卡名永久变更为「不明」的持续效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(77571455)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 自己场上表侧表示的念动力族超量怪兽的过滤条件
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- 盖放效果在自己结束阶段的发动条件判断
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在念动力族超量怪兽且当前正处于自己回合
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 盖放效果的发动准备与可行性检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息为将墓地的此卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 盖放效果的执行与离场除外限制注册
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡正常存在于墓地且未受无效影响并成功盖放到魔法与陷阱区域
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)>0 then
		-- 注册盖放的此卡从场上离开的场合除外的单体持续限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
