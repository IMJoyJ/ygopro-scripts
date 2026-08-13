--ウォークライ・オーピス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，这张卡可以不用解放作召唤。
-- ②：自己的战士族·地属性怪兽进行战斗的伤害计算后才能发动。从卡组把「战吼斗士·奥菲斯」以外的1只战士族·地属性怪兽送去墓地。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
function c46169154.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有战士族怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46169154,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c46169154.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的战士族·地属性怪兽进行战斗的伤害计算后才能发动。从卡组把「战吼斗士·奥菲斯」以外的1只战士族·地属性怪兽送去墓地。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46169154,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCountLimit(1,46169154)
	e1:SetTarget(c46169154.tgtg)
	e1:SetOperation(c46169154.tgop)
	c:RegisterEffect(e1)
end
-- 用于①的召唤条件判定：若场上存在里侧表示或非战士族怪兽，则返回true，说明不满足“只有战士族怪兽”的条件。
function c46169154.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_WARRIOR)
end
-- ①的召唤规则效果条件：仅在按不解放方式通常召唤（minc==0）、该卡等级5以上且主怪兽区有空位，并且自己场上没有怪兽或只有表侧表示战士族怪兽时，允许不用解放作召唤。
function c46169154.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认本次召唤为不解放召唤（minc==0）、这张卡等级为5以上（原本需要解放）且自己主怪兽区有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上没有怪兽，或不存在里侧表示/非战士族怪兽，即满足“自己场上的怪兽不存在或者只有战士族怪兽”的条件。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c46169154.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 筛选可送去墓地的对象：地属性、战士族、能被送去墓地，且卡名不是「战吼斗士·奥菲斯」本身。
function c46169154.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave() and not c:IsCode(46169154)
end
-- 判断传入的怪兽是否为玩家控制的地属性战士族怪兽，用于确认“自己的战士族·地属性怪兽”参与了战斗。
function c46169154.check(c,tp)
	return c and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- ②效果的发动时点判定：我方地属性战士族怪兽进行了战斗，且卡组存在符合条件的送墓对象，场上存在可上升攻击力的「战吼」怪兽；发动后将本次操作信息设为从卡组送墓。
function c46169154.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认进行战斗的攻击者或攻击目标中，至少有一个是我方控制的地属性战士族怪兽，满足“自己的战士族·地属性怪兽进行战斗”。
	if chk==0 then return (c46169154.check(Duel.GetAttacker(),tp) or c46169154.check(Duel.GetAttackTarget(),tp))
		-- 确认卡组中存在至少1张符合条件的「战吼斗士·奥菲斯」以外的战士族·地属性怪兽，保证送墓处理可以执行。
		and Duel.IsExistingMatchingCard(c46169154.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 确认自己场上存在至少1只表侧表示且未被战斗破坏确定的「战吼」怪兽，作为攻击力上升的对象。
		and Duel.IsExistingMatchingCard(c46169154.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置当前效果的操作信息：将从卡组把1张卡送去墓地（CATEGORY_TOGRAVE），供其他效果的时点判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 筛选攻击力上升对象：自己场上表侧表示的「战吼」怪兽，且没有被战斗破坏确定（尚未移离场地）的卡。
function c46169154.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果处理：先从卡组选择1张符合条件的战士族·地属性怪兽送去墓地；若送墓成功，则另起处理使我方场上所有符合条件的「战吼」怪兽攻击力上升200直到对方回合结束。
function c46169154.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足tgfilter条件的战士族·地属性怪兽（非「战吼斗士·奥菲斯」），作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c46169154.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择了卡并实际将其送入墓地，则继续执行后续的攻击力上升处理；否则不处理。
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		-- 中断当前效果链，使之后的攻击力上升处理作为独立效果处理，避免错过时点（对应“那之后”的另起处理）。
		Duel.BreakEffect()
		-- 收集当前自己场上所有满足atkfilter条件的表侧表示「战吼」怪兽，准备对其赋予攻击力上升效果。
		local sg=Duel.GetMatchingGroup(c46169154.atkfilter,tp,LOCATION_MZONE,0,nil)
		-- 遍历刚才收集到的每一只「战吼」怪兽，逐只施加攻击力变化效果。
		for tc in aux.Next(sg) do
			-- 那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			e1:SetValue(200)
			tc:RegisterEffect(e1)
		end
	end
end
