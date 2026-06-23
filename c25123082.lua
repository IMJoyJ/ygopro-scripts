--ヒュグロの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只魔法师族怪兽为对象才能发动。这个回合，那只怪兽的攻击力上升1000，以下效果适用。
-- ●那只怪兽战斗破坏对方怪兽时才能发动。从卡组把1张「魔导书」魔法卡加入手卡。
function c25123082.initial_effect(c)
	-- 创建并注册一张发动时效果，取对象，可以自由连锁，发动次数限制为1的魔法卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25123082+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25123082.target)
	e1:SetOperation(c25123082.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标是否为表侧表示的魔法师族怪兽
function c25123082.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 选择目标：选择自己场上1只表侧表示的魔法师族怪兽作为效果对象
function c25123082.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25123082.filter(chkc) end
	-- 检查阶段：确认自己场上是否存在满足条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingTarget(c25123082.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示信息：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对象：选择满足条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c25123082.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动效果：设置目标怪兽攻击力上升1000，并注册战斗破坏时检索魔导书魔法卡的效果
function c25123082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 使目标怪兽攻击力上升1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- 注册战斗破坏时检索魔导书魔法卡的效果，该效果为诱发即时效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(25123082,0))  --"检索"
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_BATTLE_DESTROYING)
		e2:SetLabelObject(tc)
		e2:SetCondition(c25123082.shcon)
		e2:SetTarget(c25123082.shtg)
		e2:SetOperation(c25123082.shop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e2,tp)
		-- 注册一个持续效果，用于替换目标怪兽被战斗破坏时的处理
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EFFECT_DESTROY_REPLACE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCondition(c25123082.regcon)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 判断目标怪兽是否在战斗中被破坏，若被破坏则记录标记
function c25123082.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetBattleTarget() and r==REASON_BATTLE then
		c:RegisterFlagEffect(25123082,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
	return false
end
-- 判断是否为被战斗破坏的怪兽，且该怪兽有标记
function c25123082.shcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(25123082)~=0
end
-- 过滤函数：判断卡是否为魔导书系列的魔法卡且能加入手牌
function c25123082.shfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息，确定要检索的卡的数量和位置
function c25123082.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认卡组中是否存在满足条件的魔导书魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25123082.shfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：表示要从卡组检索1张魔导书魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 发动检索效果：从卡组选择1张魔导书魔法卡加入手牌并确认
function c25123082.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示信息：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡牌：从卡组中选择1张满足条件的魔导书魔法卡
	local g=Duel.SelectMatchingCard(tp,c25123082.shfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
