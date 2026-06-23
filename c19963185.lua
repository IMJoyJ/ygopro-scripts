--A宝玉獣 アメジスト・キャット
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：自己的「高等宝玉兽」怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c19963185.initial_effect(c)
	-- 记录该卡具有「高等暗黑结界」这张卡的卡片密码，用于后续判断是否存在于场地区域
	aux.AddCodeList(c,12644061)
	-- 启用全局标记，使卡片在特定条件下可以不入连锁地送入墓地
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c19963185.tgcon)
	c:RegisterEffect(e1)
	-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c19963185.repcon)
	e2:SetOperation(c19963185.repop)
	c:RegisterEffect(e2)
	-- ②：自己的「高等宝玉兽」怪兽可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c19963185.atktg)
	c:RegisterEffect(e3)
	-- ②：那次直接攻击给与对方的战斗伤害变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c19963185.atkcon)
	e4:SetTarget(c19963185.atktg)
	-- 设置战斗伤害为对方受到的伤害的一半
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)
end
-- 判断场地区域是否存在「高等暗黑结界」
function c19963185.tgcon(e)
	-- 若场地区域不存在「高等暗黑结界」则返回true
	return not Duel.IsEnvironment(12644061)
end
-- 判断该卡是否为表侧表示、位于怪兽区域且因破坏而离场
function c19963185.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将该卡改变为魔法卡类型并设置为永续效果
function c19963185.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将该卡改变为魔法卡类型并设置为永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否为「高等宝玉兽」系列
function c19963185.atktg(e,c)
	return c:IsSetCard(0x5034)
end
-- 判断是否满足直接攻击的条件
function c19963185.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 若当前无攻击目标且己方怪兽区域有怪兽则返回true
	return Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
