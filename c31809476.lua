--紋章の明滅
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以对方场上的表侧表示怪兽任意数量为对象才能发动。那些怪兽的卡名当作「不明」使用。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果，设置卡名变更效果和盖放效果
function s.initial_effect(c)
	-- 记录该卡与「不明」卡的关联
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
-- 过滤函数，用于判断目标怪兽是否为表侧表示且不是「不明」
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(77571455)
end
-- 效果处理函数，选择对方场上的表侧表示怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:IsCode(77571455) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.codefilter,tp,0,LOCATION_MZONE,1,99,nil)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且为怪兽类型且与效果相关
function s.acfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
end
-- 发动效果，将选中的怪兽卡名变为「不明」
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡片组并过滤出符合条件的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.acfilter,nil,e)
	-- 遍历过滤后的怪兽组
	for tc in aux.Next(g) do
		-- 将目标怪兽的卡名变为「不明」
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(77571455)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且为念动力族超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- 盖放效果的发动条件判断函数
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方回合且己方场上有念动力族超量怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 盖放效果的目标设定函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息，提示将卡片从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 盖放效果的处理函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否能正常盖放
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c) then
		-- 设置盖放后卡片离开场上的处理，使其移至除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
