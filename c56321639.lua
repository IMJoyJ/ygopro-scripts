--魔導書廊エトワール
-- 效果：
-- 只要这张卡在场上存在，每次自己或者对方把名字带有「魔导书」的魔法卡发动，给这张卡放置1个魔力指示物。自己场上的魔法师族怪兽的攻击力上升这张卡放置的魔力指示物数量×100的数值。此外，有魔力指示物放置的这张卡被破坏送去墓地时，可以把持有这张卡放置的魔力指示物数量以下的等级的1只魔法师族怪兽从卡组加入手卡。
function c56321639.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，每次自己或者对方把名字带有「魔导书」的魔法卡发动（此效果用于在连锁发动时记录这张卡在场上存在）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_SZONE)
	-- 设置连锁记录处理：在效果发动时记录这张卡当时存在于场上，作为后续放置魔力指示物的前提判定标记
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 每次自己或者对方把名字带有「魔导书」的魔法卡发动，给这张卡放置1个魔力指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c56321639.ctcon)
	e2:SetOperation(c56321639.ctop)
	c:RegisterEffect(e2)
	-- 自己场上的魔法师族怪兽的攻击力上升这张卡放置的魔力指示物数量×100的数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设定攻击力上升效果的作用对象：自己场上的魔法师族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e3:SetValue(c56321639.atkval)
	c:RegisterEffect(e3)
	-- 有魔力指示物放置的这张卡（离场前记录这张卡放置的魔力指示物数量）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c56321639.regop)
	c:RegisterEffect(e5)
	-- 有魔力指示物放置的这张卡被破坏送去墓地时，可以把持有这张卡放置的魔力指示物数量以下的等级的1只魔法师族怪兽从卡组加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56321639,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c56321639.thcon)
	e4:SetTarget(c56321639.thtg)
	e4:SetOperation(c56321639.thop)
	e4:SetLabelObject(e5)
	c:RegisterEffect(e4)
end
c56321639.mentioned_counter={
	[0x1]=true,
}
-- 发动条件判定：连锁处理的效果是「魔导书」魔法卡的发动，且该连锁发动时这张卡在场上存在
function c56321639.ctcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local c=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and c:IsSetCard(0x106e) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 给这张卡放置1个魔力指示物
function c56321639.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 返回这张卡放置的魔力指示物数量×100的数值作为攻击力上升量
function c56321639.atkval(e,c)
	return e:GetHandler():GetCounter(0x1)*100
end
-- 在这张卡离场前，读取并记录这张卡放置的魔力指示物数量
function c56321639.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1)
	e:SetLabel(ct)
end
-- 发动条件判定：这张卡离场时曾放置有魔力指示物，且是被破坏送去墓地
function c56321639.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0 and c:IsReason(REASON_DESTROY)
end
-- 筛选条件：等级在这张卡放置的魔力指示物数量以下、可以加入手卡的魔法师族怪兽
function c56321639.filter(c,lv)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 效果对象设定：确认自己卡组存在满足条件的怪兽，并设置加入手卡的操作信息
function c56321639.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56321639.filter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置操作信息：将从自己卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让自己从卡组选择1只满足条件的魔法师族怪兽加入手卡，并向对方确认
function c56321639.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1只等级在指示物数量以下的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c56321639.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 把选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
