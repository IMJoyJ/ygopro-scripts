--義賊の極意書
-- 效果：
-- 选择自己场上表侧表示存在的1只通常怪兽发动。这个回合选择怪兽给与对方基本分战斗伤害时，对方随机丢弃2张手卡。
function c95096437.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只通常怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95096437.target)
	e1:SetOperation(c95096437.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的通常怪兽
function c95096437.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 效果发动的对象选择与合法性检测
function c95096437.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c95096437.filter(chkc) end
	-- 检查自己场上是否存在符合条件的表侧表示通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c95096437.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的通常怪兽作为效果对象
	Duel.SelectTarget(tp,c95096437.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为目标怪兽添加标识，并注册一个在造成战斗伤害时触发的全局效果
function c95096437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		tc:RegisterFlagEffect(95096437,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,0,1)
		-- 这个回合选择怪兽给与对方基本分战斗伤害时，对方随机丢弃2张手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(95096437,0))
		e1:SetCategory(CATEGORY_HANDES_OPPO)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetLabelObject(tc)
		e1:SetCondition(c95096437.hdcon)
		e1:SetTarget(c95096437.hdtg)
		e1:SetOperation(c95096437.hdop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境注册该丢弃手牌的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 丢弃手牌效果的发动条件：对方受到战斗伤害，且造成伤害的是被选择的怪兽
function c95096437.hdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return ep~=tp and eg:IsContains(tc) and tc:GetFlagEffect(95096437)~=0
end
-- 丢弃手牌效果的靶向与操作信息设置
function c95096437.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的目标玩家为发动此卡效果的玩家
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,2)
end
-- 丢弃手牌效果的具体处理：对方随机选择2张手牌送去墓地
function c95096437.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标玩家（即发动此卡效果的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方玩家的手牌
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	local dg=g:RandomSelect(tp,2)
	-- 将选中的手牌以效果丢弃的方式送去墓地
	Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
end
