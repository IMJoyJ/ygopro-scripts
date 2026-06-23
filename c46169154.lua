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
	-- ②：自己的战士族·地属性怪兽进行战斗的伤害计算后才能发动。从卡组把「战吼斗士·奥菲斯」以外的1只战士族·地属性怪兽送去墓地。那之后，自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
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
-- 过滤函数，用于判断场上是否存在非战士族或里侧表示的怪兽。
function c46169154.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_WARRIOR)
end
-- 召唤条件函数，判断是否满足不用解放作召唤的条件。
function c46169154.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否为等级5以上且场上存在空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否无怪兽或只有战士族怪兽。
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(c46169154.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 过滤函数，用于检索卡组中符合条件的战士族·地属性怪兽（非奥菲斯）。
function c46169154.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsAbleToGrave() and not c:IsCode(46169154)
end
-- 辅助函数，判断目标怪兽是否为己方控制且满足战士族·地属性条件。
function c46169154.check(c,tp)
	return c and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 效果发动时的检查函数，确认战斗中的攻击怪或防守怪为战士族·地属性，并且卡组和场上存在符合条件的怪兽。
function c46169154.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前战斗中攻击怪是否为己方控制的战士族·地属性怪兽。
	if chk==0 then return (c46169154.check(Duel.GetAttacker(),tp) or c46169154.check(Duel.GetAttackTarget(),tp))
		-- 检查卡组是否存在满足条件的战士族·地属性怪兽。
		and Duel.IsExistingMatchingCard(c46169154.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己场上有无满足条件的「战吼」怪兽。
		and Duel.IsExistingMatchingCard(c46169154.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息，提示将从卡组送去墓地一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于检索自己场上满足条件的「战吼」怪兽（即：表侧表示、属于战吼系列且未因战斗破坏）。
function c46169154.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果处理函数，选择并送入墓地一张符合条件的怪兽，并对己方所有「战吼」怪兽提升攻击力。
function c46169154.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张符合条件的战士族·地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c46169154.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将怪兽送入墓地。
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		-- 中断当前效果处理，确保后续效果按顺序执行。
		Duel.BreakEffect()
		-- 检索自己场上所有满足条件的「战吼」怪兽。
		local sg=Duel.GetMatchingGroup(c46169154.atkfilter,tp,LOCATION_MZONE,0,nil)
		-- 遍历所有符合条件的「战吼」怪兽并为其添加攻击力提升效果。
		for tc in aux.Next(sg) do
			-- 为符合条件的「战吼」怪兽增加200点攻击力，持续到对方回合结束。
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
