--トライゲート・ウィザード
-- 效果：
-- 衍生物以外的怪兽2只以上
-- ①：得到和这张卡互相连接的怪兽数量的以下效果。
-- ●1只以上：和这张卡互相连接的怪兽在和对方怪兽进行战斗的场合，那只怪兽给与对方的战斗伤害变成2倍。
-- ●2只以上：1回合1次，以场上1张卡为对象才能发动。那张卡除外。
-- ●3只：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并除外。
function c32617464.initial_effect(c)
	-- 为“三栅极男巫”添加连接召唤手续，素材要求为2只以上衍生物以外的怪兽（minc=2，maxc默认99）。
	aux.AddLinkProcedure(c,c32617464.matfilter,2)
	c:EnableReviveLimit()
	-- ●1只以上：和这张卡互相连接的怪兽在和对方怪兽进行战斗的场合，那只怪兽给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c32617464.damtg)
	-- 设置战斗伤害变更效果：使这张卡控制者的对手（1代表对手）受到的相关战斗伤害变为2倍（DOUBLE_DAMAGE），即“那只怪兽给与对方的战斗伤害变成2倍”。
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	-- ●2只以上：1回合1次，以场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32617464,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32617464.rmcon)
	e2:SetTarget(c32617464.rmtg)
	e2:SetOperation(c32617464.rmop)
	c:RegisterEffect(e2)
	-- ●3只：1回合1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32617464,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c32617464.negcon)
	-- 为第三个效果（无效并除外）设置目标函数为通用函数aux.nbtg，该函数会检查触发效果能否被无效、对应卡能否除外，并写入连锁操作信息。
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c32617464.negop)
	c:RegisterEffect(e3)
end
-- 定义连接素材过滤器：素材怪兽不得是衍生物（not c:IsLinkType(TYPE_TOKEN)），对应“衍生物以外的怪兽”。
function c32617464.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
-- 伤害变更效果的目标过滤器：仅当怪兽c与这张卡互相连接、且正在和对方怪兽战斗时，才会适用战斗伤害加倍效果。
function c32617464.damtg(e,c)
	local lg=e:GetHandler():GetMutualLinkedGroup()
	return lg:IsContains(c) and c:GetBattleTarget()~=nil and c:GetBattleTarget():GetControler()==1-e:GetHandlerPlayer()
end
-- 除外效果的发动条件：这张卡的互相连接怪兽数量不少于2只，满足“●2只以上”的条件时才能发动。
function c32617464.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>=2
end
-- 除外效果的目标选择：处理取对象，检查对象必须在场且可除外；发动时要求场上存在至少1张可除外的卡；随后提示玩家选择1张场上的卡作为对象，并声明该效果的除外操作信息。
function c32617464.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 在发动时判断是否存在至少1张可除外的场上卡片，作为效果能否发动的合法性检查。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出“请选择要除外的卡”的提示消息，引导当前玩家选取除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的卡，并将其登记为当前连锁的对象卡（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理信息，声明本次操作将把对象卡g以除外（CATEGORY_REMOVE）处理，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的结算：取得目标卡，若该卡仍与效果关联，则将其表侧表示除外。
function c32617464.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那张对象卡（本效果只选1张，所以用GetFirstTarget取得唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示将目标卡除外，除外原因为效果（REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 无效并除外效果的发动条件：本卡未被战斗破坏、当前连锁可以被无效、且互相连接怪兽数量不少于3只，三个条件需同时成立。
function c32617464.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定条件为：本卡未处于战斗破坏确定状态（STATUS_BATTLE_DESTROYED），当前连锁可被无效（IsChainNegatable），且互相连接怪兽数量≥3。
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and c:GetMutualLinkedGroupCount()>=3
end
-- 无效并除外效果的结算：先无效当前连锁，若成功且发动效果的卡仍与效果关联，则将该发动效果对应的卡组（eg）表侧表示除外。
function c32617464.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若连锁无效成功且被无效的效果的发动卡仍然与效果关联（未被中途移走），则继续执行除外操作。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将触发连锁的那张卡（eg）以表侧表示除外，实现“那个发动无效并除外”。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
