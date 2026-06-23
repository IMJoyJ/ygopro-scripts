--紋章の明滅
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以对方场上的表侧表示怪兽任意数量为对象才能发动。那些怪兽的卡名当作「不明」使用。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果：注册魔法卡发动效果以及结束阶段的墓地盖放效果
function s.initial_effect(c)
	-- 将「不明」的卡片密码加入当前卡片的关联卡片列表中
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
-- 过滤条件：筛选对方场上表侧表示且卡名不为「不明」的怪兽
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(77571455)
end
-- 效果①目标阶段：让玩家选择对方场上符合条件的怪兽作为效果的对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:IsCode(77571455) end
	-- 目标阶段检查：确认对方场上是否存在至少1只表侧表示且卡名不是「不明」的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上任意数量的符合条件的怪兽作为此效果的对象
	local g=Duel.SelectTarget(tp,s.codefilter,tp,0,LOCATION_MZONE,1,99,nil)
end
-- 过滤条件：确认作为对象的卡片依然在场上以表侧表示存在且属于怪兽卡
function s.acfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
end
-- 效果①处理阶段：将连锁中作为对象且合法的怪兽卡名改变为「不明」
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中依然在场且属于怪兽的表侧表示对象集合
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.acfilter,nil,e)
	-- 遍历符合条件的每一个怪兽卡片对象
	for tc in aux.Next(g) do
		-- 那些怪兽的卡名当作「不明」使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(77571455)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：筛选己方场上表侧表示的念动力族超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- 效果②发动条件：确认当前是自己的回合的结束阶段，且自己场上存在表侧表示的念动力族超量怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否为发动玩家的回合，且该玩家场上是否存在念动力族超量怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②目标阶段：判断这张卡在当前状态下能否进行盖放，并注册移出墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置连锁处理时的移出墓地操作信息，预计将此卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②处理阶段：将这张卡在自己场上盖放，并注册其从场上离开的场合除外的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡依然存在且没有受到王家长眠之谷等卡片限制，则将其在自己场上盖放
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c) then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
