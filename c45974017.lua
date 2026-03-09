--闇魔界の契約書
-- 效果：
-- 「暗魔界的契约书」的①的效果1回合只能使用1次。
-- ①：从以下效果选择1个才能把这个效果发动。
-- ●以自己墓地1只「DD」灵摆怪兽为对象才能发动。那只怪兽在自己的灵摆区域放置。
-- ●从自己的额外卡组把1只表侧表示的「DD」灵摆怪兽在自己的灵摆区域放置。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c45974017.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从以下效果选择1个才能把这个效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45974017,0))  --"选择1个效果发动"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,45974017)
	e2:SetTarget(c45974017.pctg)
	e2:SetOperation(c45974017.pcop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45974017,3))  --"受到1000伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c45974017.damcon)
	e3:SetTarget(c45974017.damtg)
	e3:SetOperation(c45974017.damop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为满足条件的「DD」灵摆怪兽
function c45974017.pcfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 效果处理函数，用于选择并设置发动效果的选项
function c45974017.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45974017.pcfilter(chkc) end
	-- 检查自己墓地是否存在满足条件的「DD」灵摆怪兽
	local b1=Duel.IsExistingTarget(c45974017.pcfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 检查自己额外卡组是否存在满足条件的「DD」灵摆怪兽
	local b2=Duel.IsExistingMatchingCard(c45974017.pcfilter,tp,LOCATION_EXTRA,0,1,nil)
	if chk==0 then
		-- 检查玩家场上是否有可用的灵摆区域
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
		return b1 or b2
	end
	local op=0
	-- 当两个选项都存在时，让玩家选择其中一个效果
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(45974017,1),aux.Stringid(45974017,2))  --"自己墓地1只「DD」灵摆怪兽在灵摆区放置/额外卡组1只「DD」灵摆怪兽在灵摆区放置"
	-- 当只有墓地选项存在时，让玩家选择该效果
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(45974017,1))  --"自己墓地1只「DD」灵摆怪兽在灵摆区放置"
	-- 当只有额外卡组选项存在时，让玩家选择该效果
	else op=Duel.SelectOption(tp,aux.Stringid(45974017,2))+1 end  --"额外卡组1只「DD」灵摆怪兽在灵摆区放置"
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要放置到灵摆区的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择墓地中的满足条件的「DD」灵摆怪兽
		local g=Duel.SelectTarget(tp,c45974017.pcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息，记录将要离开墓地的卡片
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	else
		e:SetProperty(0)
	end
end
-- 效果处理函数，根据选择的选项执行对应操作
function c45974017.pcop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取当前连锁的目标卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将目标卡片移动到玩家的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	else
		-- 再次检查玩家场上是否有可用的灵摆区域
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		-- 提示玩家选择要放置到灵摆区的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从额外卡组中选择满足条件的「DD」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c45974017.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的额外卡组怪兽移动到玩家的灵摆区域
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 触发条件函数，判断是否为自己的准备阶段
function c45974017.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置伤害效果的目标玩家和伤害值
function c45974017.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置伤害效果的伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息，记录将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果处理函数，对目标玩家造成伤害
function c45974017.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
