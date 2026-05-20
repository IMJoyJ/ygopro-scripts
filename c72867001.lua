--総剣司令 ソウザ
-- 效果：
-- 调整＋地属性怪兽1只以上
-- 这个卡名在规则上也当作「X-剑士」卡使用。
-- ①：这张卡的攻击力上升除外状态的怪兽数量×200。
-- ②：这张卡战斗破坏怪兽时才能发动。自己抽1张。
-- ③：1回合1次，对方把效果发动时，把自己场上1只「X-剑士」怪兽解放才能发动。对方场上1张卡破坏。
-- ④：这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1张「剑士」卡除外。
local s,id,o=GetID()
-- 初始化卡片效果的入口函数
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋地属性怪兽1只以上
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升除外状态的怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽时才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件：自身战斗破坏对方怪兽并送去墓地时
	e2:SetCondition(aux.bdcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把效果发动时，把自己场上1只「X-剑士」怪兽解放才能发动。对方场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ④：这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1张「剑士」卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.reptg)
	c:RegisterEffect(e4)
	-- 调整＋地属性怪兽1只以上
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(s.valcheck)
	c:RegisterEffect(e5)
end
-- 同调素材检测函数，用于处理可以使用多只调整作为同调素材的特殊规则
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整＋地属性怪兽1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：除外状态表侧表示的怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升数值的辅助函数
function s.value(e,c)
	-- 获取双方除外状态的表侧表示怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*200
end
-- 抽卡效果的发动准备与检测函数
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查当前玩家是否能够抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1张卡
	Duel.SetTargetParam(1)
	-- 向系统宣告此连锁包含抽卡操作，预计让当前玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 设置效果发动条件：自身未被战斗破坏，且对方发动了效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp
end
-- 过滤条件：对方场上不等于发动效果的卡且不为该卡装备卡的其他卡片
function s.desfilter(c,rc)
	return c:GetEquipTarget()~=rc and c~=rc
end
-- 解放Cost过滤条件：自己场上的「X-剑士」怪兽，且对方场上有可作为破坏对象的卡
function s.costfilter(c,tp)
	if not c:IsSetCard(0x100d) then return false end
	-- 检查对方场上是否存在可以作为破坏对象的卡
	return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,c,c)
end
-- 破坏效果的发动准备与检测函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:IsCostChecked() then
			-- 检查自己场上是否存在可解放的「X-剑士」怪兽作为发动Cost
			return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp)
		else
			-- 检查对方场上是否存在可以破坏的卡
			return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
		end
	end
	if e:IsCostChecked() then
		-- 向玩家发送选择解放卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让玩家选择自己场上1只满足条件的「X-剑士」怪兽解放
		local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
		-- 解放选中的怪兽作为发动Cost
		Duel.Release(g,REASON_COST)
	end
	-- 获取对方场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 向系统宣告此连锁包含破坏操作，预计破坏对方场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 为选中的卡片显示靶向动画效果
		Duel.HintSelection(g)
		-- 破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤条件：自己墓地可以除外的「剑士」卡
function s.repfilter(c)
	return c:IsSetCard(0xd) and c:IsAbleToRemove()
end
-- 代替破坏效果的发动准备与检测函数
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己墓地是否存在可以除外的「剑士」卡
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家发送选择代替破坏卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己墓地选择1张「剑士」卡
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的「剑士」卡除外以代替破坏
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
