--花札衛－雨四光－
-- 效果：
-- 调整＋调整以外的怪兽3只
-- ①：只要这张卡在怪兽区域存在，自己场上的「花札卫」怪兽不会被效果破坏，不会成为对方的效果的对象。
-- ②：对方抽卡阶段对方通常抽卡的场合发动。给与对方1500伤害。
-- ③：对方结束阶段从以下效果选择1个发动。
-- ●下次的自己回合的抽卡阶段跳过。
-- ●这张卡的效果直到下次的对方准备阶段无效。
function c42291297.initial_effect(c)
	-- 添加同调召唤手续，需要1只调整和3只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),3,3)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己场上的「花札卫」怪兽不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上的「花札卫」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe6))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果值为不会成为对方的效果对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 对方抽卡阶段对方通常抽卡的场合发动。给与对方1500伤害
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42291297,0))  --"给与对方1500伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DRAW)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c42291297.damcon)
	e4:SetTarget(c42291297.damtg)
	e4:SetOperation(c42291297.damop)
	c:RegisterEffect(e4)
	-- 对方结束阶段从以下效果选择1个发动。●下次的自己回合的抽卡阶段跳过。●这张卡的效果直到下次的对方准备阶段无效
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c42291297.epcon)
	e5:SetTarget(c42291297.eptg)
	e5:SetOperation(c42291297.epop)
	c:RegisterEffect(e5)
end
-- 判断是否为对方抽卡阶段且为规则抽卡
function c42291297.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE
end
-- 设置伤害对象为对方玩家，伤害值为1500
function c42291297.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为1500
	Duel.SetTargetParam(1500)
	-- 设置连锁操作信息为造成1500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 执行伤害处理，对目标玩家造成1500伤害
function c42291297.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否为对方回合
function c42291297.epcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为非自己
	return Duel.GetTurnPlayer()~=tp
end
-- 选择发动效果，若卡片可被无效则提供两个选项，否则仅提供一个选项
function c42291297.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local op=0
	-- 提示玩家选择效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 若卡片可被无效，则提供两个选项供选择
	if aux.NegateMonsterFilter(c) then op=Duel.SelectOption(tp,aux.Stringid(42291297,1),aux.Stringid(42291297,2))  --"下次的自己回合的抽卡阶段跳过/这张卡的效果直到下次的对方准备阶段无效"
	-- 若卡片不可被无效，则仅提供一个选项
	else op=Duel.SelectOption(tp,aux.Stringid(42291297,1)) end  --"下次的自己回合的抽卡阶段跳过"
	if op==0 then
		e:SetCategory(0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		-- 设置连锁操作信息为使效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,c,1,0,0)
	end
	e:SetLabel(op)
end
-- 执行效果处理，根据选择结果跳过抽卡阶段或使效果无效
function c42291297.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 创建使对方抽卡阶段跳过的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		-- 将效果注册给指定玩家
		Duel.RegisterEffect(e1,tp)
	elseif c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使与该卡片相关的连锁无效化
		Duel.NegateRelatedChain(c,RESET_TURN_SET)
		-- 创建使该卡片效果无效的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		c:RegisterEffect(e2)
	end
end
