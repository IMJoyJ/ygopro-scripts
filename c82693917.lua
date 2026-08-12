--フォーチュンレディ・ウインディー
-- 效果：
-- 这张卡的攻击力·守备力变成这张卡的等级×300的数值。自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。这张卡召唤成功时，可以把自己场上表侧表示存在的名字带有「命运女郎」的怪兽数量的对方场上存在的魔法·陷阱卡破坏。
function c82693917.initial_effect(c)
	-- 这张卡的攻击力·守备力变成这张卡的等级×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c82693917.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82693917,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c82693917.lvcon)
	e3:SetOperation(c82693917.lvop)
	c:RegisterEffect(e3)
	-- 这张卡召唤成功时，可以把自己场上表侧表示存在的名字带有「命运女郎」的怪兽数量的对方场上存在的魔法·陷阱卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82693917,1))  --"魔法·陷阱卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c82693917.destg)
	e4:SetOperation(c82693917.desop)
	c:RegisterEffect(e4)
end
-- 计算并返回该怪兽等级×300的数值
function c82693917.value(e,c)
	return c:GetLevel()*300
end
-- 检查当前回合玩家是否为自己
function c82693917.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段等级上升效果的处理：若自身表侧表示存在、未离场且等级小于12，则等级上升1星
function c82693917.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的名字带有「命运女郎」的怪兽
function c82693917.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31)
end
-- 过滤条件：魔法·陷阱卡
function c82693917.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 召唤成功时破坏魔法·陷阱卡效果的发动准备与目标确认
function c82693917.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上表侧表示的「命运女郎」怪兽数量
		local ct=Duel.GetMatchingGroupCount(c82693917.cfilter,tp,LOCATION_MZONE,0,nil)
		-- 获取对方场上存在的魔法·陷阱卡数量
		local dt=Duel.GetMatchingGroupCount(c82693917.filter,tp,0,LOCATION_ONFIELD,nil)
		e:SetLabel(ct)
		return dt>=ct
	end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c82693917.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的操作信息，指定目标为对方场上的魔陷，数量为自己场上「命运女郎」怪兽的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,e:GetLabel(),0,0)
end
-- 召唤成功时破坏魔法·陷阱卡效果的实际处理
function c82693917.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己场上表侧表示的「命运女郎」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c82693917.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 重新获取当前对方场上存在的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c82693917.filter,tp,0,LOCATION_ONFIELD,nil)
	if ct>g:GetCount() then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,ct,ct,nil)
	-- 显式示出被选择的卡片
	Duel.HintSelection(sg)
	-- 因效果破坏选中的卡片
	Duel.Destroy(sg,REASON_EFFECT)
end
