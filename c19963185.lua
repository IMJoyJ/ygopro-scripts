--A宝玉獣 アメジスト・キャット
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：自己的「高等宝玉兽」怪兽可以直接攻击。那次直接攻击给与对方的战斗伤害变成一半。
-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c19963185.initial_effect(c)
	-- 将卡号12644061（「高等暗黑结界」）记录为这张卡上记载的卡名，用于后续调用 IsEnvironment 等判定环境中是否存在该卡。
	aux.AddCodeList(c,12644061)
	-- 启用全局标记 GLOBALFLAG_SELF_TOGRAVE，使 EFFECT_SELF_TOGRAVE 效果能被正确执行，以支持①中无场地时这张卡自我送去墓地的处理。
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
	-- 那次直接攻击给与对方的战斗伤害变成一半。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(c19963185.atkcon)
	e4:SetTarget(c19963185.atktg)
	-- 将伤害变更效果设为：对玩家1（对方玩家）造成的战斗伤害变为一半。
	e4:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e4)
end
-- 定义①效果的条件：当场上不存在卡号为12644061的「高等暗黑结界」时，条件成立，该怪兽会送去墓地。
function c19963185.tgcon(e)
	-- 返回当前没有「高等暗黑结界」的判定结果，满足时触发自我送墓。
	return not Duel.IsEnvironment(12644061)
end
-- 定义③效果的条件：这张卡表侧表示存在于怪兽区域，且被破坏时条件成立。
function c19963185.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 定义③效果的操作：将这张卡变成永续魔法卡，使其在被破坏时可以不送去墓地，作为永续魔法卡放置在魔法与陷阱区域。
function c19963185.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 筛选「高等宝玉兽」（0x5034）怪兽，作为②效果的目标范围。
function c19963185.atktg(e,c)
	return c:IsSetCard(0x5034)
end
-- 定义伤害减半的追加条件：当前攻击为直接攻击（攻击对象为空）且对方场上有怪兽存在。
function c19963185.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判定为直接攻击且对方场上有怪兽，两者同时满足时触发战斗伤害减半。
	return Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
