--不死之炎鳥
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡给与对方玩家战斗伤害的场合，自己的基本分回复那个战斗伤害的数值。
function c38538445.initial_effect(c)
	-- 调用辅助函数为这张卡添加灵魂怪兽效果：在召唤或反转成功的回合的结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的判定值设为恒为 false，使这张卡在所有情况下都无法被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡给与对方玩家战斗伤害的场合，自己的基本分回复那个战斗伤害的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38538445,1))  --"回复"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c38538445.condition)
	e4:SetTarget(c38538445.target)
	e4:SetOperation(c38538445.operation)
	c:RegisterEffect(e4)
end
-- 诱发效果的发动条件：受到战斗伤害的玩家 ep 不是这张卡的控制者 tp，即此卡给与对方玩家战斗伤害时才满足条件。
function c38538445.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动时的目标处理：在合法检查（chk==0）时返回 true；在实际发动时，将对象玩家设为此卡控制者 tp，对象参数设为本次战斗伤害 ev，并登记回复类别的操作信息。
function c38538445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁的对象玩家设为此卡控制者 tp，即要回复基本分的玩家。
	Duel.SetTargetPlayer(tp)
	-- 把当前连锁对象参数设为 ev（本次战斗伤害数值），作为要回复的基本分数值。
	Duel.SetTargetParam(ev)
	-- 向系统登记本次连锁的操作信息为“回复”类别：目标玩家为 tp，目标参数为 ev；targets 为 nil 表示不取对象，供相关卡片的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理：从当前连锁信息中取出对象玩家和参数，执行回复基本分的操作。
function c38538445.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家 p（回复者）和对象参数 d（回复数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家 p 回复 d 点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
