--紋章の明滅
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以对方场上的表侧表示怪兽任意数量为对象才能发动。那些怪兽的卡名当作「不明」使用。
-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：记录「不明」卡名，注册①效果（魔陷发动型、取对象、自由时点）和②效果（墓地发动的结束阶段诱发选发效果，1回合1次）
function s.initial_effect(c)
	-- 登记这张卡上记载着「不明」（卡号77571455）的卡名，便于效果中引用该卡名
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
	-- ②：自己结束阶段，这张卡在墓地存在，自己场上有念动力族超量怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。（这个卡名的②的效果1回合只能使用1次）
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
-- 对象过滤函数：表侧表示且卡名不是「不明」（77571455）的卡
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(77571455)
end
-- ①效果的对象处理：检查发动条件，提示并选择对方场上任意数量的表侧表示怪兽作为效果对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:IsCode(77571455) end
	-- 发动条件检查：对方场上存在至少1只可以作为对象的、表侧表示且卡名不是「不明」的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择效果的对象」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1至99只表侧表示且卡名不是「不明」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.codefilter,tp,0,LOCATION_MZONE,1,99,nil)
end
-- 效果处理过滤函数：表侧表示、为怪兽且仍与这个效果关联（对象在处理时仍然有效）的卡
function s.acfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e)
end
-- ①效果的处理：取得连锁的对象卡，逐个为它们注册改变卡名为「不明」的永续效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组，并过滤出仍有效的表侧表示怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.acfilter,nil,e)
	-- 遍历对象卡片组中的每一张卡
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
-- ②效果条件过滤函数：表侧表示的念动力族超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- ②效果的发动条件：自己的结束阶段且自己场上存在念动力族超量怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是自己的回合，并且自己场上存在至少1只表侧表示的念动力族超量怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的对象处理：确认这张卡可以盖放，并设置离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：宣言这张卡将因效果离开墓地（用于星尘龙、王家长眠之谷等的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果的处理：这张卡与效果关联且不受王家长眠之谷影响时在自己场上盖放，并注册离场时除外的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联、不受王家长眠之谷影响，并将这张卡在自己场上盖放成功
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SSet(tp,c)>0 then
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
