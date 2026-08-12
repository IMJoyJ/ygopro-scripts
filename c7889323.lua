--鉄獣の死線
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有兽族·兽战士族·鸟兽族怪兽特殊召唤的场合，以自己的除外状态的1只「铁兽」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己的「铁兽」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽回到手卡。
function c7889323.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上有兽族·兽战士族·鸟兽族怪兽特殊召唤的场合，以自己的除外状态的1只「铁兽」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7889323,0))  --"回收除外怪兽"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,7889323)
	e1:SetCondition(c7889323.thcon)
	e1:SetTarget(c7889323.thtg)
	e1:SetOperation(c7889323.thop)
	c:RegisterEffect(e1)
	-- ②：自己的「铁兽」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7889323,1))  --"对方怪兽回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,7889324)
	e2:SetCondition(c7889323.bacon)
	e2:SetTarget(c7889323.batg)
	e2:SetOperation(c7889323.baop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的兽族、兽战士族或鸟兽族怪兽。
function c7889323.spfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsControler(tp)
end
-- 检查特殊召唤的怪兽中是否存在自己场上的兽族、兽战士族或鸟兽族怪兽，作为效果发动的条件。
function c7889323.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7889323.spfilter,1,nil,tp)
end
-- 过滤除外状态的、表侧表示的「铁兽」怪兽卡，且该卡能加入手卡。
function c7889323.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择，确认是否存在可加入手卡的除外「铁兽」怪兽，并将其设为效果对象。
function c7889323.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c7889323.thfilter(chkc) end
	-- 在发动阶段检查自己的除外状态是否存在至少1只满足条件的「铁兽」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c7889323.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1只自己除外状态的「铁兽」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c7889323.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息，表明此效果的操作是将选中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理，将作为对象的除外怪兽加入手卡。
function c7889323.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定，检查是否为自己的「铁兽」怪兽与对方怪兽进行战斗，并记录对方怪兽。
function c7889323.bacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local ac=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(bc)
	return ac:IsFaceup() and ac:IsControler(tp) and ac:IsSetCard(0x14d) and bc:IsControler(1-tp)
end
-- 效果②的发动准备，确认进行战斗的对方怪兽是否能回到手卡。
function c7889323.batg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if not bc then return false end
	if chk==0 then return bc:IsAbleToHand() end
	-- 设置效果处理信息，表明此效果的操作是将进行战斗的对方怪兽送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,bc,1,0,0)
end
-- 效果②的效果处理，将进行战斗的对方怪兽送回手卡。
function c7889323.baop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 通过效果将进行战斗的对方怪兽送回持有者的手卡。
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
