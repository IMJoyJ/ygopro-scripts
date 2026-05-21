--至高の木の実
-- 效果：
-- 这张卡的发动时，自己基本分比对方低的场合，自己回复2000基本分。自己基本分比对方高的场合，自己受到1000分伤害。
function c98380593.initial_effect(c)
	-- 这张卡的发动时，自己基本分比对方低的场合，自己回复2000基本分。自己基本分比对方高的场合，自己受到1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c98380593.rectg)
	e1:SetOperation(c98380593.recop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与类型检测
function c98380593.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 第一阶段检测：必须是卡片发动，且双方基本分不能相等（相等时无法发动）
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetLP(tp)~=Duel.GetLP(1-tp) end
	-- 设置效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 判断自己基本分是否比对方低
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		e:SetLabel(0)
		-- 设置效果参数为2000（回复量）
		Duel.SetTargetParam(2000)
		-- 设置操作信息为回复自己2000基本分
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
	else
		e:SetLabel(1)
		-- 设置效果参数为1000（伤害量）
		Duel.SetTargetParam(1000)
		-- 设置操作信息为自己受到1000分伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
	end
end
-- 效果处理的执行函数
function c98380593.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if e:GetLabel()==0 then
		-- 执行回复基本分的操作
		Duel.Recover(p,d,REASON_EFFECT)
	else
		-- 执行给予伤害的操作
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
