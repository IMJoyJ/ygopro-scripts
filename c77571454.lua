--No.69 紋章神コート・オブ・アームズ－ゴッド・レイジ
-- 效果：
-- 4星怪兽×5
-- ①：场上的这张卡不会被战斗·效果破坏。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名当作「不明」使用。
-- ③：只要这张卡在怪兽区域存在，对方发动的「不明」的效果无效化。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将卡片「不明」加入此卡的关联卡片列表中
	aux.AddCodeList(c,77571455)
	-- 设置超量召唤手续：4星怪兽×5
	aux.AddXyzProcedure(c,nil,4,5)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名当作「不明」使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"卡名变更"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(s.codecost)
	e3:SetTarget(s.codetg)
	e3:SetOperation(s.codeop)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，对方发动的「不明」的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 设置该怪兽的「No.」编号为69
aux.xyz_number[id]=69
-- 卡名变更效果的Cost：取除1个超量素材
function s.codecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：对方场上表侧表示且卡名不是「不明」的怪兽
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(id+o)
end
-- 卡名变更效果的目标选择函数
function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:IsCode(id+o) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.codefilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 卡名变更效果的实际处理函数
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的卡名当作「不明」使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(id+o)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 无效化效果的触发条件判定：对方发动的「不明」的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if rp~=1-tp then return false end
	if re:GetHandler():IsRelateToEffect(re) then
		return re:GetHandler():IsCode(id+o)
	else
		-- 获取触发效果的卡片密码，用于判定是否为「不明」
		local code,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		return code==id+o or code2==id+o
	end
end
-- 无效化效果的实际处理函数
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在画面上显示这张卡发动效果的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
